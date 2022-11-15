#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

ibmcloud login --apikey ${IC_API_KEY} -r us-south -q || exit 1
ibmcloud sl sshkey sshkey-remove ${SSHKEY_ID} -f
