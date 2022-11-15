#!/bin/bash

eval "$(jq -r '@sh "PKI_PATH=\(.pki_path) USERID=\(.userid) REGION=\(.region)"')"

ca_cert=$(base64 ${PKI_PATH}/ca.crt)
client_cert=$(base64 ${PKI_PATH}/issued/${USERID}-${REGION}.vpn.ibm.com.crt)
client_key=$(base64 ${PKI_PATH}/private/${USERID}-${REGION}.vpn.ibm.com.key)

jq -n --arg ca_cert "$ca_cert" \
      --arg client_cert "$client_cert" \
      --arg client_key "$client_key" \
      '{"ca_cert": $ca_cert, "client_cert": $client_cert, "client_key": $client_key}'
