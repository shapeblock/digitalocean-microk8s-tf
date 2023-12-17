variable "region" {
  type        = string
  description = "DigitalOcean region"
}


variable "dns" {
  type = string
}

variable "image" {
  type        = string
  default     = "ubuntu-22-04-x64"
  description = "Base image for the VMs"
}

variable "node_group_config" {
  type = list(object({
    name  = string
    size  = string
    count = number
  }))
  description = "Node group configuration for VM deployment"
}

variable "tld" {
  type    = string
  default = "shapeblockapp.com"
}

variable "sb_url" {
  type = string
}

variable "cluster_uuid" {
  type = string
}

// TODO: Set Kubernetes version
// TODO: Add cluster name and ID for tagging purposes
