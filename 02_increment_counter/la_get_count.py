#!/usr/bin/env python

import logging

import la_increment_lib


def lambda_handler(event, context):
    """Retrieves a given CountName, perhaps derived from API Gateway information."""
    logging.warning("DEBUG: {r}".format(r=repr(event)))
    try:
        CountName = la_increment_lib.parse_event(event, "GET")
        if CountName is None:
            return la_increment_lib.make_return("event must specify CountName", 400)
        ddb, tables = la_increment_lib.ddb_connect()
        count_value = la_increment_lib.conditional_get_count(CountName, tables)
        return la_increment_lib.make_return("count is {c}".format(c=count_value['count']), 200)
    except:
        logging.exception("Caught unknown error")
        return la_increment_lib.make_return("unknown error", 400)
