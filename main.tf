terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.8.0"
    }
    dnsimple = {
      source = "dnsimple/dnsimple"
      version = "1.1.2"
    }    
  }

  backend "pg" {
  }
}

locals {
  vms = flatten([
    for node_group in var.node_group_config : [
      for i in range(node_group.count) : {
        name  = "${node_group.name}-${i}"
        size  = node_group.size
        group = node_group.name
      }
    ]
  ])
}

resource "random_id" "ssh_key_id" {
  byte_length = 8
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
}

// TODO: change naming convention
resource "digitalocean_ssh_key" "ssh_key" {
  name       = "terraform-ssh-key-${random_id.ssh_key_id.hex}"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

// TODO: Add tags to all resources
resource "digitalocean_vpc" "vpc" {
  name   = var.vpc
  region = var.region
}

resource "digitalocean_droplet" "vm" {
  for_each = {
    for vm in local.vms : vm.name => vm
  }
  name       = each.value.name
  region     = digitalocean_vpc.vpc.region
  size       = each.value.size
  image      = var.image
  vpc_uuid   = digitalocean_vpc.vpc.id
  ssh_keys   = [digitalocean_ssh_key.ssh_key.id]
  tags       = ["shapeblock", each.value.group]
  monitoring = true # Enable monitoring if desired
}

data "digitalocean_droplets" "vms" {
  for_each = {
    for node_group in var.node_group_config : node_group.name => node_group
  }
  filter {
    key    = "tags"
    values = ["shapeblock", each.key]
    all    = true
  }
  depends_on = [digitalocean_droplet.vm]
}

locals {
  inventory = templatefile("${path.module}/hosts.tpl", {
    ha_host     = lookup(data.digitalocean_droplets.vms, var.node_group_config.0.name).droplets.0.name
    ha_ip       = lookup(data.digitalocean_droplets.vms, var.node_group_config.0.name).droplets.0.ipv4_address
    node_groups = var.node_group_config
    vms         = data.digitalocean_droplets.vms
  })
}

resource "local_file" "inventory" {
  content  = local.inventory
  filename = "${path.module}/inventory"
}

resource "local_file" "data" {
  content  = jsonencode({ private = tls_private_key.ssh_key.private_key_pem, public = tls_private_key.ssh_key.public_key_pem, inventory = local.inventory })
  filename = "${path.module}/data"
}
