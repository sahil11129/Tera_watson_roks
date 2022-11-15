resource "local_file" "home" {
  content  = "home folder"
  filename = "${path.module}/home/home.txt"
}

data "ibm_resource_group" "resource_group" {
  name = var.resource_group_name
}

// get VLAN ids
data "external" "vlan" {
  program = ["bash", "${path.module}/scripts/get-vlan.sh"]
  query = {
    ibmcloud_api_key = var.ibmcloud_api_key
    datacenter       = var.datacenter
  }
}

data "external" "capacity" {
  program = ["bash", "${path.module}/scripts/available.sh"]
  query = {
    cloudAccount = var.cloudAccount
    datacenter   = var.datacenter
  }
}

resource "ibm_container_cluster" "cluster" {
  name                    = var.cluster_name
  datacenter              = data.capacity.result.datacenter
  default_pool_size       = var.compute_nodes_count
  machine_type            = var.compute_nodes_flavor
  hardware                = "shared"
  resource_group_id       = data.ibm_resource_group.resource_group.id
  kube_version            = "${var.ocp_version}_openshift"
  public_vlan_id          = data.external.vlan.result.publicVLAN
  private_vlan_id         = data.external.vlan.result.privateVLAN
  force_delete_storage    = true
  tags                    = [var.user_id, var.requestId]
  public_service_endpoint = true

  timeouts {
    create = "3h"
    delete = "3h"
  }
}

resource "ibm_iam_access_group" "cluster_accgrp" {
  name        = "cluster-${var.cluster_name}"
  description = "Cluster Access Group for ${var.cluster_name}"
  depends_on = [
    ibm_container_cluster.cluster
  ]
}

resource "ibm_iam_access_group_policy" "policy" {
  access_group_id = ibm_iam_access_group.cluster_accgrp.id
  roles           = ["Manager", "Operator", "Viewer"]

  resources {
    service              = "containers-kubernetes"
    resource_instance_id = ibm_container_cluster.cluster.id
  }
}

data "ibm_iam_access_group" "shared_accgroup" {
  access_group_name = var.shared_access_group_name
}

#### Invite user and add to the groups
resource "null_resource" "invite_user" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/invite-user.sh || true"
    environment = {
      HOME               = "${abspath(path.module)}/home"
      API_KEY            = var.ibmcloud_api_key
      SHARED_GROUP_NAME  = var.shared_access_group_name
      CLUSTER_GROUP_NAME = ibm_iam_access_group.cluster_accgrp.name
      EMAIL              = var.user_email
    }
  }
  depends_on = [
    ibm_iam_access_group.cluster_accgrp
  ]
}

# Download kubeconfig for the cluster
resource "null_resource" "kubeconfig" {

  provisioner "local-exec" {
    command = "${path.module}/scripts/get-kubeconfig.sh || true"
    environment = {
      HOME        = "${abspath(path.module)}/home"
      API_KEY     = var.ibmcloud_api_key
      CLUSTERNAME = ibm_container_cluster.cluster.id
    }
  }

  depends_on = [
    ibm_container_cluster.cluster
  ]
}

resource "null_resource" "add_user_rbac" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/add-user-rbac.sh || true"
    environment = {
      HOME    = "${abspath(path.module)}/home"
      EMAIL   = var.user_email
      USER_ID = var.user_id
    }
  }
  depends_on = [
    ibm_container_cluster.cluster,
    null_resource.kubeconfig
  ]
}
