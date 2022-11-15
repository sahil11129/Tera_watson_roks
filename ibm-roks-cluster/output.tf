output "resource_group_id" {
  description = "Resource Group ID"
  value       = data.ibm_resource_group.resource_group.id
}

output "cluster_id" {
  description = "Cluster ID"
  value       = ibm_container_cluster.cluster.id
}

output "cluster_name" {
  description = "Cluster Name"
  value       = ibm_container_cluster.cluster.name
}

output "cluster_url" {
  description = "Cluster URL"
  value       = "https://cloud.ibm.com/kubernetes/clusters/${ibm_container_cluster.cluster.id}/overview?bss_account=${data.ibm_iam_access_group.shared_accgroup.id}"
}

output "server_url" {
  description = "Cluster Name"
  value       = ibm_container_cluster.cluster.server_url
}

output "ocp_version" {
  description = "OCP Version"
  value       = ibm_container_cluster.cluster.kube_version
}