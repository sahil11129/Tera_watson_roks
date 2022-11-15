output "service_name" {
  description = "Service Name"
  value       = var.resource_name
}

output "service_url" {
  description = "Service URL"
  value       = ibm_resource_instance.resource.dashboard_url
}

output "service_plan" {
  description = "Service Plan"
  value       = ibm_resource_instance.resource.plan
}

output "access_group_name" {
  description = "Access Group"
  value       = ibm_iam_access_group.cluster_accgrp.name
}


