#!/usr/bin/env python

import logging

import la_increment_lib


def lambda_handler(event, context):
    """Increments a given CountName, possibly derived from api_gateway info.  If CountName does not exist,
    conditional_get_count will return a zero, so this function will increment and return 1."""
    logging.warning("DEBUG: {r}".format(r=repr(event)))
    try:
        CountName = la_increment_lib.parse_event(event, "POST")
        if CountName is None:
            return la_increment_lib.make_return("event must specify CountName", 400)
        ddb, tables = la_increment_lib.ddb_connect()
        count_value = la_increment_lib.conditional_get_count(CountName, tables)
        la_increment_lib.increment_count(count_value)
        la_increment_lib.set_count(CountName, count_value, tables)
        return la_increment_lib.make_return("count is {c}".format(c=count_value['count']), 200)
    except:
        logging.exception("Caught unknown error")
        return la_increment_lib.make_return("unknown error", 400)
