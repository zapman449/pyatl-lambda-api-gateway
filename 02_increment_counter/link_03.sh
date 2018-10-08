#!/bin/bash

if [[ "$1" == "unlink" ]] ; then
    echo "unlinking all files"
    for f in tf_api_gw.tf; do
        rm -f $f
    done
else
    echo "linking all files"
    for f in tf_api_gw.tf; do
        if [[ ! -h $f ]]; then
            if echo $f | grep "\.py$" >/dev/null ; then
                cp ../03_api_gateway/$f .
            else
                ln -s ../03_api_gateway/$f
            fi
        fi
    done
fi
