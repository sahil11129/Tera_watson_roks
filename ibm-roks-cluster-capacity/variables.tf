variable "resource_group_name" {
  description = "Resource Group for Cluster"
  type        = string
  default     = "dteroks"
}

variable "shared_access_group_name" {
  description = "Shared Access Group for Users"
  type        = string
  default     = "dteroks-users"
}

# Definded by reservation-ms
variable "datacenter" {
  description = "Datacenter"
  type        = string
  default     = "dal13"
}

variable "compute_nodes_count" {
  description = "Worker Node Count"
  type        = number
  default     = 3
}

variable "compute_nodes_flavor" {
  description = "Worker Node Flavor"
  type        = string
  default     = "b3c.4x16"
}

variable "ocp_version" {
  description = "OpenShift Version"
  type        = string
  default     = "4.6"
}

variable "cluster_name" {
  description = "Cluster Name"
  type        = string
}

variable "user_email" {
  type = string
}

variable "user_id" {
  type = string
}

variable "requestId" {
  type    = string
  default = "NoRequestID"
}

variable "cloudAccount" {
  type    = string
  default = ""
}
