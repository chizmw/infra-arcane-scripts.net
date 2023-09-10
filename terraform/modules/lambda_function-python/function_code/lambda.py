import json


# this is the generic GET handler for /scripts
# we don't have a general collection of scripts so we just returna "not implemented" message


def get__scripts(event, context):
    response_body = {"message": "not implemented", "request_id": context.aws_request_id}
    response_body_string = json.dumps(response_body, default=str)

    return {
        "statusCode": 501,
        "headers": {
            "Content-Type": "application/json",
        },
        "body": response_body_string,
    }


if __name__ == "__main__":
    print(get__scripts(None, None))
