#!/usr/bin/env python

import json
import logging
import os
import sys

import boto3


def ddb_connect():
    ddb = boto3.resource('dynamodb')
    tables = dict()
    table_name = os.environ.get("INCREMENTATION_TABLE_NAME")
    if table_name is None:
        table_name = 'incrementation'
    tables['incrementation'] = ddb.Table(table_name)
    return ddb, tables


def valid_ddb_response_q(response):
    if 'ResponseMetadata' in response:
        if 'HTTPStatusCode' in response['ResponseMetadata']:
            if response['ResponseMetadata']['HTTPStatusCode'] == 200:
                return True
    return False


def conditional_get_count(CountName, tables):
    response = tables['incrementation'].get_item(
        Key={
            'CountName': CountName
        }
    )
    if not valid_ddb_response_q(response):
        msg = "got error querying incrementation table: {}".format(repr(response))
        logging.error(msg)
        raise Exception(msg)
    elif 'Item' in response:
        count_value = json.loads(response['Item']['CountValue'])
        logging.warning("count_value found.  Looks like: {c}".format(c=repr(count_value)))
        return True, count_value
    else:
        logging.warning("no count_value found in conditional_get. Returning None")
        return False, None


def set_count(CountName, count_value, tables):
    response = tables['incrementation'].put_item(
        Item={
            "CountName": CountName,
            "CountValue": json.dumps(count_value)
        }
    )
    if valid_ddb_response_q(response):
        return True
    else:
        msg = "failed to put new count"
        logging.error(msg)
        raise Exception(msg)


def parse_event(event, expected_method):
    result = None
    if 'CountName' in event:
        result = event['CountName']
    elif 'resource' in event and 'path' in event and 'httpMethod' in event:
        # logging.warning("DEBUG: event->resource is {}".format(event['resource']))
        # logging.warning("DEBUG: event->httpMethod is {}".format(event['httpMethod']))
        # logging.warning("DEBUG: event->path is {}".format(event['path']))
        if event['resource'] == "/counts/{CountName}":
            if event['httpMethod'] == expected_method:
                path_words = event['path'].split('/')
                result = path_words[2]
    return result


def make_return(msg, code):
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
