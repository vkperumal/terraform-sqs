package main

import (
	"encoding/json"
	"fmt"
	"log"
	"strings"

	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sqs"
	"github.com/slack-go/slack"
)

var sess = session.Must(session.NewSession())
var svc = sqs.New(sess, &aws.Config{Region: aws.String("ap-south-1")})

func SlackNotify(severity string, alert string, sqs string, metric string, threshold string, region string, webhook string) {
	var color string
	var text string
	if alert == "OK" {
		color = "good"
		text = fmt.Sprintf("[*Resolved*] *SQS Alert*\n%s metric in %s queue on %s region is below threshold %v\nSeverity: %s", metric, sqs, region, threshold, severity)
	} else {
		color = "danger"
		text = fmt.Sprintf("[*Firing*] *SQS Alert*\n%s metric in %s queue on %s region is above threshold %v\nSeverity: %s", metric, sqs, region, threshold, severity)
	}
	attachment := slack.Attachment{
		Color: color,
		Text:  text,
	}
	msg := slack.WebhookMessage{
		Attachments: []slack.Attachment{attachment},
	}
	err := slack.PostWebhook(webhook, &msg)
	if err != nil {
		log.Fatalln("Slack Notification Failed")
	}
}

func sqsAction(queue string) (o string, err error) {
	sqsUrlInput := &sqs.GetQueueUrlInput{
		QueueName: aws.String(queue),
	}
	resp, err := svc.GetQueueUrl(sqsUrlInput)
	if err != nil {
		log.Printf("there was an error describe queue of %s\n", queue)
		log.Fatal(err.Error())
		return o, err
	}
	listTagsInput := &sqs.ListQueueTagsInput{
		QueueUrl: resp.QueueUrl,
	}
	res, err := svc.ListQueueTags(listTagsInput)
	if err != nil {
		log.Printf("there was an error describe queue tags of %s\n", queue)
		log.Fatal(err.Error())
		return o, err
	}
	for k, tagRes := range res.Tags {
		if k == "Owner" {
			o = aws.StringValue(tagRes)
			return o, err
		}
	}
	return o, err
}

func HandleRequest(event map[string]interface{}) (*string, error) {
	if event == nil {
		return nil, fmt.Errorf("received nil event")
	}
	log.Println(event)
	var severity string
	message := fmt.Sprintf("%s", event["Records"].([]interface{})[0].(map[string]interface{})["Sns"].(map[string]interface{})["Message"])
	result := make(map[string]interface{})
	json.Unmarshal([]byte(message), &result)
	severity_type := fmt.Sprintf("%s", result["AlarmName"])
	alert := fmt.Sprintf("%s", result["NewStateValue"])
	metric := fmt.Sprintf("%s", result["Trigger"].(map[string]interface{})["MetricName"])
	threshold := fmt.Sprintf("%v", result["Trigger"].(map[string]interface{})["Threshold"])
	sqsqueue := fmt.Sprintf("%s", result["Trigger"].(map[string]interface{})["Dimensions"].([]interface{})[0].(map[string]interface{})["value"])
	region := fmt.Sprintf("%s", result["Region"])
	if strings.Contains(severity_type, "warning") {
		severity = "warning"
	} else {
		severity = "critical"
	}

	tag, _ := sqsAction(sqsqueue)
	var webhook string
	switch {
	case tag == "qa":
		webhook = "" // team specific channel webhook url
	default:
		webhook = "" // common channel webhook url
	}
	if fmt.Sprintf("%s", result["OldStateValue"]) != "INSUFFICIENT_DATA" {
		SlackNotify(severity, alert, sqsqueue, metric, threshold, region, webhook)
	}
	return nil, nil
}

func main() {
	lambda.Start(HandleRequest)
}
