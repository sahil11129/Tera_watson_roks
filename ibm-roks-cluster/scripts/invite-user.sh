#!/bin/bash

# Jason E - 8/1/22 - improve error handling

# Exit if any of the intermediate steps fail
#set -e

max_retry=5
retry=1
success="yes"
while [ ${retry} -lt ${max_retry} ]
do
	ibmcloud login --apikey ${API_KEY} -q > /dev/null || success="no"
	ibmcloud account user-invite ${EMAIL} --access-groups ${SHARED_GROUP_NAME},${CLUSTER_GROUP_NAME} || success="no"
	if [[ "$success" == "no" ]]
	then
	  sleep 15
	  (( retry = retry + 1 ))
	  success="yes"
	else
	  exit 0
	fi
done

echo "Failed to login and invite user"
exit 1

#echo $(ibmcloud login --apikey ${API_KEY}) > /dev/null

#ibmcloud account user-invite ${EMAIL} --access-groups ${SHARED_GROUP_NAME},${CLUSTER_GROUP_NAME}
