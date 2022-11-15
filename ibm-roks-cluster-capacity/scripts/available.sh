#!/bin/bash

CAPACITYHOST=https://capacity.itzmonitoring-3195e5b101a2fc76b9c4875fb79cfa25-0000.us-south.containers.appdomain.cloud/api

# Exit if any of the intermediate steps fail
set -e

# Get inputs
eval "$(jq -r '@sh "ACCOUNT=\(.cloudAccount) DC=\(.datacenter)"')"

# Lookup capacity
request="$CAPACITYHOST/available/$ACCOUNT/$DC"
#echo "request: $request"

# Request next available
curl $request
