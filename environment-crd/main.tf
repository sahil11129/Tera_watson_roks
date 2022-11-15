resource "local_file" "environment" {
  content = jsonencode({
    "cloudAccount"    = var.cloudAccount
    "cloudTarget"     = var.cloudTarget
    "cloudpakStatus"  = "complete"
    "clusterId"       = var.clusterId
    "clusterName"     = var.clusterName
    "clusterStatus"   = "normal"
    "clusterURL"      = var.clusterURL
    "consoleURL"      = var.consoleURL
    "dataCenter"      = var.datacenter
    "deploy_status"   = "complete"
    "owner"           = var.owner
    "ownerStatus"     = "complete"
    "region"          = var.datacenter
    "registryStatus"  = "complete"
    "resourceGroup"   = var.resourceGroup
    "resourceGroupID" = var.resourceGroupID
    "template"        = var.template
    "workerCount"     = var.workerCount
  })
  filename = "${path.module}/environment.json"
}

resource "null_resource" "create_environment" {
  triggers = {
    env_server  = var.env_server
    env_auth = var.env_auth
    clusterName   = var.clusterName
  }

  provisioner "local-exec" {
    environment = {
      SERVER = self.triggers.env_server
      auth = self.triggers.env_auth
    }
    command     = "./itzenv new --env $(cat environment.json) || true"
    working_dir = path.module
    on_failure  = continue
  }

  depends_on = [
    local_file.environment
  ]
}