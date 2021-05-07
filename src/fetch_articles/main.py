import datetime
import os
from aws_lambda_powertools import Logger, Tracer
import boto3
from boto3.dynamodb.conditions import Key
import feedparser


logger = Logger()
tracer = Tracer()


TABLE_NAME = os.environ["TABLE_NAME"]
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(TABLE_NAME)


@logger.inject_lambda_context(log_event = True)
@tracer.capture_lambda_handler
def handler(event, _):
    feed = event["feed"]
    timestamp = event["timestamp"]

    feed_data = feedparser.parse(feed)

    articles = {}

    logger.info({
        "feed_data": feed_data
    })

    # Parse entries
    for entry in feed_data.entries:
        logger.info({
            "entry": entry
        })

        # TODO: use another way to find newer articles
        try:
            entry_timestamp = int(datetime.datetime(*entry.published_parsed[:7]).timestamp())
        except AttributeError:
            entry_timestamp = datetime.datetime.now().timestamp()
        if entry_timestamp < timestamp:
            continue

        articles[entry.link] = {
            "link": entry.link,
            "title": entry.title,
            "description": entry.description,
            "timestamp": entry_timestamp
        }

    # Store articles in DynamoDB
    with table.batch_writer() as writer:

        for article_link, article in articles.items():

            writer.put_item(
                Item={
                    "pk": f"feed#{feed}",
                    "sk": f"article#{article_link}",
                    "title": article["title"],
                    "description": article["description"]
                }
            )

    # Return article information
    return [
        {
            "feed": feed,
            "link": article["link"],
            "title": article["title"]
        }
        for article_link, article in articles.items()
    ]