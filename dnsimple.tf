resource "dnsimple_zone_record" "ingress" {
  zone_name = var.tld
  name      = var.dns
  value     = lookup(data.digitalocean_droplets.vms, var.node_group_config.0.name).droplets.0.ipv4_address
  type      = "A"
  ttl       = 3600
}


resource "dnsimple_zone_record" "cname" {
  zone_name = var.tld
  name      = "*.${var.dns}"
  value     = "${var.dns}.${var.tld}"
  type      = "CNAME"
  ttl       = 3600
}
