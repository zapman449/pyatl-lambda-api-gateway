#!/usr/bin/env python

import logging

import la_increment_lib


def lambda_handler(event, context):
    logging.warning("DEBUG: {r}".format(r=repr(event)))
    try:
        if 'CountName' in event:
            CountName = event['CountName']
        else:
            return {"statusCode": 400, "body": "event must specify CountName"}
        ddb, tables = la_increment_lib.ddb_connect()
        count_exists, count_value = la_increment_lib.conditional_get_count(CountName, tables)
        if count_exists is True:
            count_value['count'] = count_value['count'] + 1
        else:
            count_value = {'count': 1}
        la_increment_lib.set_count(CountName, count_value, tables)
        return {"statusCode": 200, "body": "count is {c}".format(c=count_value['count'])}
    except:
        logging.exception("Caught unknown error")
        return {"statusCode": 400, "body": "unknown error"}
