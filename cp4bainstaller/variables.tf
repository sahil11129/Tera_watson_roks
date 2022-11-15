variable "ibmcloud_api_key" {
  description = "IBM Cloud API Key"
  type = string
}

variable "user_email" {
  type = string
}

variable "cluster_name" {
  description = "Cluster Name/ID"
  type = string
}

variable "entitlmentkey" {
  type    = string
  default = "eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE1ODc1OTIzMTAsImp0aSI6IjM1NmM4ZjVkODdlODQ0YTk4NGIwM2E0MmQ1M2Y0MTg3In0.uUov23VT5eqV3bKzJYuJ1-IAQMteiqBsZ_BVi-tz024"
}

variable "CASEVERSION" {
  type    = string
  default = "3.2.2"
}

variable "CP4BAVERSION" {
  type    = string 
  default = "21.0.3"
}
