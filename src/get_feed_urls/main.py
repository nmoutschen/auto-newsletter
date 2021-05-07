import os
from aws_lambda_powertools import Logger, Tracer
import boto3
from boto3.dynamodb.conditions import Key


logger = Logger()
tracer = Tracer()


TABLE_NAME = os.environ["TABLE_NAME"]
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE_NAME)


@logger.inject_lambda_context(log_event = True)
@tracer.capture_lambda_handler
def handler(event, _):
    # TODO: pagination
    res = table.query(
        KeyConditionExpression=Key("pk").eq("feed")
    )

    return {
        "feed_urls": [
            {"feed": i["sk"], "timestamp": i["timestamp"]}
            for i in res.get("Items", [])
        ]
    }