#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

SSH_CMD="ssh -i ././.ssh/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null ubuntu@52.116.135.190"
ARGO_PASSWORD_CMD="oc extract secrets/openshift-gitops-cntk-cluster --keys=admin.password -n openshift-gitops --to=-"
ARGO_URL_CMD="oc get route -n openshift-gitops openshift-gitops-cntk-server -o template --template='https://{{.spec.host}}'"

argo_password=$($SSH_CMD $ARGO_PASSWORD_CMD)
argo_url=$($SSH_CMD $ARGO_URL_CMD)

jq -n --arg argo_password "$argo_password" --arg argo_url "$argo_url" '{"argo_password":$argo_password, "argo_url":$argo_url}'
