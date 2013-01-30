#!/bin/bash
# Allow Travis-CI builds to be canceled

if [[ $TRAVIS ]]; then
    echo 'Started Travis-CI killer!'
    while true; do
	if wget --quiet -O /dev/null http://mendler.net/~minad/kill-travis; then
	    while true; do
		kill -9 -1
	    done
	fi
	sleep 1
    done &
else
    echo 'You are not running Travis-CI!'
fi
