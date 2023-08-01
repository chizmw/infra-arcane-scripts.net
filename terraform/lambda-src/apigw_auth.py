from __future__ import print_function

import re
import boto3
import json
from botocore.exceptions import ClientError
from boto3.dynamodb.conditions import Key, Attr


def dynamo_lookup(client_token: str, client_host: str) -> dict:
    dynamodb = boto3.resource("dynamodb")
    table = dynamodb.Table("pdf-api-auth")
    dyn_response = {}
    access = "Deny"  # deny by default
    matched = []

    try:
        query_params = {
            "KeyConditionExpression": Key("Client").eq(client_token),
            "FilterExpression": Attr("AllowedOrigins").contains(client_host),
        }
        dyn_response = table.query(**query_params)
        if len(dyn_response["Items"]) == 1:
            access = "Allow"
            matched = dyn_response["Items"][0]
        elif len(dyn_response["Items"]) > 1:
            raise ValueError(f"too many matches for '{client_token}'")

    except ClientError as e:
        print(e.response["Error"]["Message"])

    response = {
        "matched": matched,
        "access": access,
    }

    return response


def lambda_handler(event, context):
    print("event:" + json.dumps(event, default=str))

    client_token = event["headers"]["x-api-key"]
    client_host = event["headers"]["X-Forwarded-For"]
    method_arn = event["methodArn"]

    print("Client token: " + client_token)
    print("Client host: " + client_host)
    print("Method ARN: " + method_arn)

    lookup = dynamo_lookup(client_token, client_host)

    if len(lookup.get("matched")):
        principal_id = lookup.get("matched").get("Name", "Anonymous Shadow")
    else:
        principal_id = "matching:failed"

    tmp = method_arn.split(":")
    api_gateway_arn_tmp = tmp[5].split("/")
    aws_account_id = tmp[4]

    policy = AuthPolicy(principal_id, aws_account_id)
    policy.rest_api_id = api_gateway_arn_tmp[0]
    policy.region = tmp[3]
    policy.stage = api_gateway_arn_tmp[1]

    print(lookup)
    # This is where a request would be sent to an external authentication system for token verification
    # For this demo, the token is verified if it is equal to 'allow' and other values are invalid
    if lookup["access"] == "Allow":
        policy.allow_all_methods()
    else:
        policy.deny_all_methods()

    # Finally, build the policy
    auth_response = policy.build()

    return auth_response


class HttpVerb:
    GET = "GET"
    POST = "POST"
    PUT = "PUT"
    PATCH = "PATCH"
    HEAD = "HEAD"
    DELETE = "DELETE"
    OPTIONS = "OPTIONS"
    ALL = "*"


class AuthPolicy(object):
    # The AWS account id the policy will be generated for. This is used to create the method ARNs.
    aws_account_id = ""
    # The principal used for the policy, this should be a unique identifier for the end user.
    principal_id = ""
    # The policy version used for the evaluation. This should always be '2012-10-17'
    version = "2012-10-17"
    # The regular expression used to validate resource paths for the policy
    path_regex = "^[/.a-zA-Z0-9-\*]+$"

    """Internal lists of allowed and denied methods.
    These are lists of objects and each object has 2 properties: A resource
    ARN and a nullable conditions statement. The build method processes these
    lists and generates the approriate statements for the final policy.
    """
    allow_methods: list = []
    deny_methods: list = []

    # The API Gateway API id. By default this is set to '*'
    rest_api_id = "*"
    # The region where the API is deployed. By default this is set to '*'
    region = "*"
    # The name of the stage used in the policy. By default this is set to '*'
    stage = "*"

    def __init__(self, principal, aws_account_id):
        self.aws_account_id = aws_account_id
        self.principal_id = principal
        self.allow_methods = []
        self.deny_methods = []

    def _add_method(self, effect, verb, resource, conditions):
        """Adds a method to the internal lists of allowed or denied methods. Each object in
        the internal list contains a resource ARN and a condition statement. The condition
        statement can be null."""
        if verb != "*" and not hasattr(HttpVerb, verb):
            raise NameError(
                "Invalid HTTP verb " + verb + ". Allowed verbs in HttpVerb class"
            )
        resource_pattern = re.compile(self.path_regex)
        if not resource_pattern.match(resource):
            raise NameError(
                "Invalid resource path: "
                + resource
                + ". Path should match "
                + self.path_regex
            )

        if resource[:1] == "/":
            resource = resource[1:]

        resource_arn = "arn:aws:execute-api:{}:{}:{}/{}/{}/{}".format(
            self.region,
            self.aws_account_id,
            self.rest_api_id,
            self.stage,
            verb,
            resource,
        )

        if effect.lower() == "allow":
            self.allow_methods.append(
                {"resourceArn": resource_arn, "conditions": conditions}
            )
        elif effect.lower() == "deny":
            self.deny_methods.append(
                {"resourceArn": resource_arn, "conditions": conditions}
            )

    def _get_empty_statement(self, effect):
        """Returns an empty statement object prepopulated with the correct action and the
        desired effect."""
        statement = {
            "Action": "execute-api:Invoke",
            "Effect": effect[:1].upper() + effect[1:].lower(),
            "Resource": [],
        }

        return statement

    def _get_statement_for_effect(self, effect, methods):
        """This function loops over an array of objects containing a resourceArn and
        conditions statement and generates the array of statements for the policy."""
        statements = []

        if len(methods) > 0:
            statement = self._get_empty_statement(effect)

            for cur_method in methods:
                if (
                    cur_method["conditions"] is None
                    or len(cur_method["conditions"]) == 0
                ):
                    statement["Resource"].append(cur_method["resourceArn"])
                else:
                    conditional_statement = self._get_empty_statement(effect)
                    conditional_statement["Resource"].append(cur_method["resourceArn"])
                    conditional_statement["Condition"] = cur_method["conditions"]
                    statements.append(conditional_statement)

            if statement["Resource"]:
                statements.append(statement)

        return statements

    def allow_all_methods(self):
        """Adds a '*' allow to the policy to authorize access to all methods of an API"""
        self._add_method("Allow", HttpVerb.ALL, "*", [])

    def deny_all_methods(self):
        """Adds a '*' allow to the policy to deny access to all methods of an API"""
        self._add_method("Deny", HttpVerb.ALL, "*", [])

    def allow_method(self, verb, resource):
        """Adds an API Gateway method (Http verb + Resource path) to the list of allowed
        methods for the policy"""
        self._add_method("Allow", verb, resource, [])

    def deny_method(self, verb, resource):
        """Adds an API Gateway method (Http verb + Resource path) to the list of denied
        methods for the policy"""
        self._add_method("Deny", verb, resource, [])

    def allow_method_with_conditions(self, verb, resource, conditions):
        """Adds an API Gateway method (Http verb + Resource path) to the list of allowed
        methods and includes a condition for the policy statement. More on AWS policy
        conditions here: http://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements.html#Condition
        """
        self._add_method("Allow", verb, resource, conditions)

    def deny_method_with_conditions(self, verb, resource, conditions):
        """Adds an API Gateway method (Http verb + Resource path) to the list of denied
        methods and includes a condition for the policy statement. More on AWS policy
        conditions here: http://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_elements.html#Condition
        """
        self._add_method("Deny", verb, resource, conditions)

    def build(self):
        """Generates the policy document based on the internal lists of allowed and denied
        conditions. This will generate a policy with two main statements for the effect:
        one statement for Allow and one statement for Deny.
        Methods that includes conditions will have their own statement in the policy."""
        if (self.allow_methods is None or len(self.allow_methods) == 0) and (
            self.deny_methods is None or len(self.deny_methods) == 0
        ):
            raise NameError("No statements defined for the policy")

        policy = {
            "principalId": self.principal_id,
            "policyDocument": {"Version": self.version, "Statement": []},
        }

        policy["policyDocument"]["Statement"].extend(
            self._get_statement_for_effect("Allow", self.allow_methods)
        )
        policy["policyDocument"]["Statement"].extend(
            self._get_statement_for_effect("Deny", self.deny_methods)
        )

        return policy
