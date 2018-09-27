#!/usr/bin/env python

import json
import logging
import os

import boto3


def lambda_handler(event, context):
    try:
        if 'CountName' in event:
            CountName = event['CountName']
        else:
            return {"statusCode": 400, "body": "event must specify CountName"}
        ddb, tables = ddb_connect()
        count_exists, count_value = conditional_get_count(CountName, tables)
        if count_exists is True:
            count_value['count'] = count_value['count'] + 1
        else:
            count_value = {'count': 1}
        set_count(CountName, count_value, tables)
        return {"statusCode": 200, "body": "count is {c}".format(c=count_value['count'])}
    except:
        logging.exception("Caught unknown error")
        return {"statusCode": 400, "body": "unknown error"}


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
