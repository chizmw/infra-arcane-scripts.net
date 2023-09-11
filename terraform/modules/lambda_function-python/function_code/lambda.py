from datetime import datetime
import json
import boto3


# this is the generic GET handler for /scripts
# we don't have a general collection of scripts so we just returna "not implemented" message
def slash_scripts(event, context):
    response_body = {
        "message": "not implemented",
        "request_id": context.aws_request_id,
        "status": "received",
    }
    response_body_string = json.dumps(response_body, default=str)
    event_string = json.dumps(event, default=str)

    insert_or_update_status(
        request_id=context.aws_request_id, status="received", event=event_string
    )

    return {
        "statusCode": 501,
        "headers": {
            "Content-Type": "application/json",
        },
        "body": response_body_string,
    }


def slash_status(event, context):
    response_body = {
        "message": "status lookup not implemented",
        "request_id": context.aws_request_id,
        "status": "UNKNOWN",
    }
    response_body_string = json.dumps(response_body, default=str)

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json",
        },
        "body": response_body_string,
    }


def insert_or_update_status(request_id: str, status: str, event: str):
    # we have a dynamodb table called "api_status-dev" with:
    # CallID (string, partition key)
    # status (string)
    # event (string)
    # LastUpdatedAt (string)

    # we need to insert or update the status for the request_id
    # if the request_id already exists, we need to update the status
    # if the request_id does not exist, we need to insert the request_id and status

    # get the dynamodb table client
    dynamodb = boto3.resource("dynamodb")
    table = dynamodb.Table("api_status-dev")

    # now() in a string format
    now = datetime.now().strftime("%Y-%m-%dT%H:%M:%S.%f")

    # insert or update the status for the request_id
    table.put_item(
        Item={
            "CallID": request_id,
            "Status": status,
            "Event": event,
            "LastUpdatedAt": now,
        }
    )


if __name__ == "__main__":
    print("This is the lambda.py file, not intended to be run directly")
