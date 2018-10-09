#!/usr/bin/env python

import logging

import increment_lib


def lambda_handler(event, context):
    """Retrieves a given CountName, perhaps derived from API Gateway information."""
    logging.warning("DEBUG: {r}".format(r=repr(event)))
    try:
        CountName = increment_lib.parse_event(event, "GET")
        if CountName is None:
            return increment_lib.make_return("event must specify CountName", 400)
        ddb, tables = increment_lib.ddb_connect()
        count_value = increment_lib.conditional_get_count(CountName, tables)
        return increment_lib.make_return("count is {c}".format(c=count_value['count']), 200)
    except:
        logging.exception("Caught unknown error")
        return increment_lib.make_return("unknown error", 400)
