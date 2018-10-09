#!/usr/bin/env python

"""
Library to support the incrementer lambda work
"""

import json
import logging
import os
import sys

import boto3


def ddb_connect():
    """connect to the correct dynamoDB tables. Returns the dynamoDB client, and the table object in a
    dictionary of relevant table objects"""
    ddb = boto3.resource('dynamodb')
    tables = dict()
    table_name = os.environ.get("INCREMENTATION_TABLE_NAME")
    if table_name is None:
        table_name = 'incrementation'
    tables['incrementation'] = ddb.Table(table_name)
    return ddb, tables


def __valid_ddb_response_q(response):
    """private function to validate a given DynamoDB query response."""
    if 'ResponseMetadata' in response:
        if 'HTTPStatusCode' in response['ResponseMetadata']:
            if response['ResponseMetadata']['HTTPStatusCode'] == 200:
                return True
    return False


# TODO: Change the data model to leaverage DynamoDB's atomic update feature:
# https://linuxacademy.com/blog/amazon-web-services-2/dynamodb-atomic-counters/
def conditional_get_count(CountName, tables):
    """Retrieves the CountName from DynamoDB if it exists.  If it does not, return a zero value"""
    response = tables['incrementation'].get_item(
        Key={
            'CountName': CountName
        }
    )
    if not __valid_ddb_response_q(response):
        msg = "got error querying incrementation table: {}".format(repr(response))
        logging.error(msg)
        raise Exception(msg)
    elif 'Item' in response:
        count_value = json.loads(response['Item']['CountValue'])
        logging.warning("count_value found.  Looks like: {c}".format(c=repr(count_value)))
        return count_value
    else:
        logging.warning("no count_value found in conditional_get. Returning zero")
        return {'count': 0}


def increment_count(count_value):
    """Take a count and increment it."""
    try:
        count_value['count'] = count_value['count'] + 1
    except KeyError:
        logging.exception("in increment_count, count_value should have key of count, but does not.")
        raise


def set_count(CountName, count_value, tables):
    """Sets a given count_value for CountName"""
    response = tables['incrementation'].put_item(
        Item={
            "CountName": CountName,
            "CountValue": json.dumps(count_value)
        }
    )
    if __valid_ddb_response_q(response):
        return True
    else:
        msg = "failed to put new count"
        logging.error(msg)
        raise Exception(msg)


def parse_event(event, expected_method):
    """Parses the event object passed in via Lambda invocation or API Gateway.  If its a Lambda inviocation,
    expects to find a CountName key and use that.  If not, it does some sanity checking for 3 keys set by
    API Gateway: resource, path, and httpMethod.  If those 3 look right, it extracts the CountName from the
    event['path']."""
    # TODO: If you're using this for real, this needs to be a lot more defensive, particularly the path_words
    # and result line.
    result = None
    if 'CountName' in event:
        result = event['CountName']
    elif 'resource' in event and 'path' in event and 'httpMethod' in event:
        if event['resource'] == "/counts/{CountName}":
            if event['httpMethod'] == expected_method:
                path_words = event['path'].split('/')
                result = path_words[2]
    return result


def make_return(msg, code):
    """Create a standardized returnable dictionary."""
    result = {
        "statusCode": int(code),
        "body": str(msg),
        "headers": {
            'Content-Type': "application/json"
        }
    }
    return result


if __name__ == "__main__":
    sys.exit("I am a library.")
