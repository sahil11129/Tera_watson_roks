#!/bin/bash

eval "$(jq -r '@sh "VPN_NAME=\(.vpn_name) IBMCLOUD_API_KEY=\(.ibmcloud_api_key) REGION=\(.region)"')"


ibmcloud login --apikey ${IBMCLOUD_API_KEY} -r ${REGION} > /dev/null 2>&1
vpn_hostname=$(ibmcloud is vpn-server ${VPN_NAME} --output json | jq -r .hostname)

jq -n --arg vpn_hostname "$vpn_hostname" '{"vpn_hostname": $vpn_hostname}'
