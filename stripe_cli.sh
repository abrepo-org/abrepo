#!/usr/bin/bash
#
# Notes:
# Does not listen to resent events from dashboard, needs newly generated events
# -a: uses already setup webhook urls from prod
# -forward-to: hostname only (use definitions with -a)
# --skip-verify: https skip

./docker_run.sh 'stripe listen --skip-verify -a --forward-to localhost:8081'

# ./docker_run.sh 'stripe listen --skip-verify -a --forward-to localhost:8081 --log-level debug'
# ./docker_run.sh 'stripe listen --print-secret'
