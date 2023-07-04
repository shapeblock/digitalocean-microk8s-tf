terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.8.0"
    }
  }

  backend "pg" {
  }
}

resource "random_id" "ssh_key_id" {
  byte_length = 8
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
}

resource "digitalocean_ssh_key" "ssh_key" {
  name       = "terraform-ssh-key-${random_id.ssh_key_id.hex}"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "digitalocean_vpc" "vpc" {
  name   = var.vpc
  region = var.region
}

resource "digitalocean_droplet" "vm" {
  count      = length(var.node_group_config)
  name       = "${var.node_group_config[count.index].name}-${count.index}"
  region     = digitalocean_vpc.vpc.region
  size       = var.node_group_config[count.index].size
  image      = var.image
  vpc_uuid   = digitalocean_vpc.vpc.id
  ssh_keys   = [digitalocean_ssh_key.ssh_key.id]
  monitoring = true # Enable monitoring if desired
}
