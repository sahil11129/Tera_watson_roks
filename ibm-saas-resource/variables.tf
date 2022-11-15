########################################
# Provider Variables
########################################
variable "ibmcloud_api_key" {
  description = "IBM Cloud API Key"
  type        = string
}

# Cloud Provider ID
variable "cloud_provider" {
  description = "Cloud Provider"
  type        = string
  default     = "ibmcloud"
}

########################################
# Module Variables
########################################
variable "resource_name" {
  type    = string
}

variable "resource_type" {
  type    = string
}

variable "resource_plan" {
  type    = string
}

variable "resource_group" {
  type    = string
}

variable "datacenter" {
  type    = string
}

variable "tags" {
  type    = list(string)
}

variable "roles" {
  type    = list(string)
}

variable "access_group_name" {
  type    = string
  default = "ag_name"
}