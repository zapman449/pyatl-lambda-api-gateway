#!/usr/bin/env python

import json
import logging


def lambda_handler(event, context):
    logging.warning(repr(event))
    logging.warning(repr(context))
    return {
        "statusCode": 200,
        "body": json.dumps('Hello from Lambda!')
    }
