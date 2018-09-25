#!/usr/bin/env python

import logging


def lambda_handler(event, context):
    logging.warning(repr(event))
    logging.warning(repr(context))
    try:
        return {
            "statusCode": 200,
            "body": "hello from lambda"
        }
    except:
        logging.exception("Caught unknown error")
        return {
            "statusCode": 400,
            "body": "unknown error"
        }
