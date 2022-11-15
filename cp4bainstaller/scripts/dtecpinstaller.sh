#!/bin/bash
#------------------------------------------------------------------------------
#-- ${FUNCNAME[1]} == Calling function's name
#-- Colors escape seqs
YEL='\033[1;33m'
CYN='\033[0;36m'
GRN='\033[1;32m'
RED='\033[1;31m'
NRM='\033[0m'

function log {
  echo -e "${CYN}[${FUNCNAME[1]}]${NRM} INFO: $*"
}

function warn {
  echo -e "${CYN}[${FUNCNAME[1]}]${NRM} ${YEL}WARN${NRM}: $*"
}

function error {
  echo -e "${CYN}[${FUNCNAME[1]}]${NRM} ${RED}ERROR${NRM}: $*"
  exit 1
}

function fatal {
  echo -e "${CYN}[${FUNCNAME[1]}]${NRM} ${RED}FATAL${NRM}: $*"
  exit 1
}

log "Staring cp4ba install"

#************************************
# Variable Setup
#
export NAMESPACE=cp4ba
export CP4BA_AUTO_PLATFORM="ROKS"
export CP4BA_AUTO_DEPLOYMENT_TYPE="starter"
export CP4BA_AUTO_NAMESPACE="$NAMESPACE"
export CP4BA_AUTO_CLUSTER_USER="IAM#$OWNER"
export CP4BA_AUTO_STORAGE_CLASS_FAST_ROKS="managed-nfs-storage"
export CP4BA_AUTO_ENTITLEMENT_KEY="$ENTITLEKEY"
export CP4BA_AUTO_ALL_NAMESPACES="No"
dlver="$CASEVERSION"
cp4baver="$CP4BAVERSION"
download="https://raw.githubusercontent.com/IBM/cloud-pak/master/repo/case/ibm-cp-automation/$dlver/ibm-cp-automation-$dlver.tgz"

#************************************
# Access Cluster
#
log "Cloud Account Login"
ibmcloud login -r us-south -q || exit 1

log "Installing the Kubernetes Service plug-in..."
ibmcloud plugin install container-service -f

log "IBMCLOUD CLI Plugins..."
ibmcloud plugin list 

log "INFO" "Cluster Login"
ibmcloud ks cluster config --admin -c ${CLUSTERNAME} -q || exit 1

#************************************
# Setup for install
#
log "Creating Namespace"
oc create ns ${NAMESPACE}
oc project ${NAMESPACE}

log "Setting up Service Accounts"
cat << EOF | oc create -n cp4ba -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ibm-cp4ba-anyuid
imagePullSecrets:
- name: "admin.registrykey"

---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ibm-cp4ba-privileged
imagePullSecrets:
- name: "admin.registrykey"
EOF

oc adm policy add-scc-to-user privileged -z ibm-cp4ba-privileged -n ${NAMESPACE}
oc adm policy add-scc-to-user anyuid -z ibm-cp4ba-anyuid -n ${NAMESPACE}

#************************************
# Download installer
#
log "Download and expand case installer"
STARTDIR=${PWD}
curl -o "ibm-cp-automation-$dlver.tgz" $download
tar -zxf "ibm-cp-automation-$dlver.tgz"
log "Expand cert-k8s installer"
cd ibm-cp-automation/inventory/cp4aOperatorSdk/files/deploy/crs 
tar xf cert-k8s-$cp4baver.tar 
cd ${STARTDIR}

#************************************
# Run cp4ba admin setup
#
log "Running cp4a-clusteradmin-setup.sh"
STARTDIR=${PWD}
cd ibm-cp-automation/inventory/cp4aOperatorSdk/files/deploy/crs/cert-kubernetes/scripts

# Fix common script, JE - needed to fix issue from product installer not finding the "cp" command
sed -i'.bak' '/set_global_env_vars/a \
COPY_CMD="/bin/cp"' ./helper/common.sh

# Fix installer key verify
sed -i'.bak' 's/entitlement_verify_passed=""/entitlement_verify_passed="passed"/' cp4a-clusteradmin-setup.sh

chmod +x "cp4a-clusteradmin-setup.sh"
./cp4a-clusteradmin-setup.sh || fatal "Error running cp4ba admin setup"
cd ${STARTDIR}

log "Adding ICP4ACluster definition to cluster"
#cd /runner/cp4fullba21.0.2
oc project $NAMESPACE
oc create -f cp4ba.yaml || fatal "Error initiating CP4BA install"

# JAE - Workaround fix for BTS
log "Apply BTS Fix"
FOUNDBTS="no"
COUNT=0
MAXCOUNT=36
while [[ "$FOUNDBTS" == "no" ]]
do 
  COUNT=$(($COUNT+1))
  log "Checking for BTS ($COUNT/$MAXCOUNT)"
  btssa=$(oc get sa | grep bts | awk '{print $1}')
  if [[ "$btssa" != "" ]]
  then
    oc secrets link "$btssa" admin.registrykey --for=pull
    FOUNDBTS="yes"
  fi
  log "Waiting for BTS"
  sleep 300
done

exit 0
