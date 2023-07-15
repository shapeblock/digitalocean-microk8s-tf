output "public_key" {
  value = tls_private_key.ssh_key.public_key_pem
}

output "private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true
}

output "ha_ip" {
  value = lookup(data.digitalocean_droplets.vms, var.node_group_config.0.name).droplets.0.ipv4_address
}
