#!/bin/bash

# Exit if any of the intermediate steps fail
set -e

eval "$(jq -r '@sh "API_KEY=\(.ibmcloud_api_key) ZONE=\(.datacenter)"')"

echo $(ibmcloud login --apikey ${API_KEY}) > /dev/null

i="0"
re='^[0-9]+$'
publicVLAN=noVLAN
privateVLAN=noVLAN

# dump vlans
vlans=$(ibmcloud sl vlan list -d ${ZONE} --output json) #MS save in memory

while ! [[ $publicVLAN =~ $re ]] && ! [[ $privateVLAN =~ $re ]] && [[ $i -lt 10 ]]; do
    #publicVLAN=$(ibmcloud sl vlan list -d ${ZONE} --output json | jq -c '.[] | select(.networkSpace | contains("PUBLIC")) | select(.subnetCount<38)' | jq -r .id | head -n 1)
    # publicVLAN=$(jq -c '.[] | select(.networkSpace | contains("PUBLIC")) | select(.subnetCount<38)' vlans.json | jq -r .id | head -n 1)
    # publicRouter=$(jq --argjson id $publicVLAN '.[] | select(.id==$id) | .primaryRouter.hostname' vlans.json | cut -b 4-6)
    # privateVLAN=$(jq --arg r $publicRouter -c '.[] | select(.networkSpace | contains("PRIVATE")) | select(.primaryRouter.hostname | contains($r)) | select(.subnetCount<38)' vlans.json | jq -r .id | head -n 1)

    publicVLANobj=$(jq -c '[.[] | select(.networkSpace | contains("PUBLIC"))] | min_by(.subnetCount) | reduce . as $item ({}; . + {"id": ($item.id), "router": ($item.primaryRouter.hostname)})' <<< "$vlans")
    publicVLAN=$(echo $publicVLANobj | jq -r '.id')
    publicRouter=$(echo $publicVLANobj | jq -r '.router')
    privateRouter=$(echo $publicRouter | sed 's/fcr/bcr/g')
    privateVLAN=$(jq --arg privateRouter "$privateRouter" '.[] | select(.primaryRouter.hostname | contains($privateRouter))' <<< "$vlans" | jq -r '.id' | head -n 1) #JE - 091321 - need to grab first only
    i=$[$i+1]
    sleep 5
done

if ! [[ $publicVLAN =~ $re ]] || ! [[ $privateVLAN =~ $re ]]; then
    echo "Unable to get VLANs for ${ZONE}. Please try again." 1>&2
    exit 1
fi

jq -n --arg publicVLAN "$publicVLAN" --arg privateVLAN "$privateVLAN" '{"publicVLAN":$publicVLAN, "privateVLAN":$privateVLAN}'
