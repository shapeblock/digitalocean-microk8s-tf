provider "dnsimple" {
  token = "TLK9gsTiCT2LuDTwABaiDXzUuA2BTgls"
  account = "88397"
}


resource "dnsimple_zone_record" "ingress" {
  zone_name = "shapeblock.xyz"
  name   = var.dns
  value  = lookup(data.digitalocean_droplets.vms, var.node_group_config.0.name).droplets.0.ipv4_address
  type   = "A"
  ttl    = 3600
}
