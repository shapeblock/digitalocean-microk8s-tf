[microk8s_HA]
${ha_host} ansible_ssh_host=${ha_ip}


[microk8s_WORKERS]
%{ for node_group,info in vms ~}
%{ for droplet in info.droplets ~}
%{ if droplet.name != ha_host ~}
${droplet.name} ansible_ssh_host=${droplet.ipv4_address}
%{ endif ~}
%{ endfor ~}
%{ endfor ~}


[all:vars]
ansible_ssh_user=root
ansible_ssh_private_key_file=private-key
microk8s_version=1.27/stable
ansible_ssh_extra_args='-o StrictHostKeyChecking=no'