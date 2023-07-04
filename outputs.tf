output "droplet_ips" {
  value = { for i, droplet in digitalocean_droplet.vm : var.node_group_config[i].name => droplet.ipv4_address }
}

output "private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}
