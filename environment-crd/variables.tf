variable "cloudAccount" {
  type    = string
  default = ""
}

variable "cloudTarget" {
  type    = string
  default = ""
}

variable "cloudpakStatus" {
  type    = string
  default = ""
}

variable "clusterName" {
  type    = string
  default = ""
}

variable "clusterId" {
  type    = string
  default = ""
}

variable "clusterURL" {
  type    = string
  default = ""
}

variable "consoleURL" {
  type    = string
  default = ""
}

variable "datacenter" {
  type    = string
  default = ""
}

variable "owner" {
  type    = string
  default = ""
}

variable "ownerStatus" {
  type    = string
  default = "complete"
}

variable "resourceGroup" {
  type    = string
  default = ""
}

variable "resourceGroupID" {
  type    = string
  default = ""
}

variable "template" {
  type    = string
  default = ""
}

variable "workerCount" {
  type    = number
  default = 0
}

variable "env_server" {
  type    = string
  default = "https://environments.itzmonitoring-3195e5b101a2fc76b9c4875fb79cfa25-0000.us-south.containers.appdomain.cloud"
}

variable "env_auth" {
  type    = string
  default = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoibm9ib2R5In0.3s4gS1OfwolS4cCrD8fQtxJxivVi0F3wIEwWIE4n2CI"
}