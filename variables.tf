variable "region" {
  type        = string
  description = "DigitalOcean region"
}


variable "vpc" {
  type = string
}

variable "image" {
  type        = string
  default     = "ubuntu-18-04-x64"
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
