########################################
# Provider Intilization
########################################
provider "ibm" {
  region           = var.datacenter
  ibmcloud_api_key = var.ibmcloud_api_key
}

terraform {
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.30.2"
    }
  }
}

########################################
# IBM Cloud Resource
########################################
resource "ibm_resource_instance" "resource" {
  name              = var.resource_name
  service           = var.resource_type
  plan              = var.resource_plan
  location          = var.datacenter
  resource_group_id = var.resource_group
  tags              = var.tags
  //User can increase timeouts
  timeouts {
    create = "15m"
    update = "15m"
    delete = "15m"
  }
}

########################################
# IBM Cloud Access Group
########################################
resource "ibm_iam_access_group" "cluster_accgrp" {
  name        = "saas-${var.resource_name}"
  description = "${var.resource_type} access group for ${var.resource_name}"
}

########################################
# IBM Cloud Access Group Policy
########################################
resource "ibm_iam_access_group_policy" "policy" {
  access_group_id = ibm_iam_access_group.cluster_accgrp.id
  roles           = var.roles

  resources {
    service              = var.resource_type
    resource_instance_id = ibm_resource_instance.resource.guid
  }
  depends_on = [
    ibm_resource_instance.resource
  ]
}
