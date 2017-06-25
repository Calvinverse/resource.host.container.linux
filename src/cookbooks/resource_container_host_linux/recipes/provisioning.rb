# frozen_string_literal: true

#
# Cookbook Name:: resource_container_host_linux
# Recipe:: provisioning
#
# Copyright 2017, P. van der Velde
#

#
# CONFIGURE THE PROVISIONING SCRIPT
#

# Create the provisioning script
file '/etc/init.d/provision.sh' do
  action :create
  content <<~BASH
    #!/bin/bash

    function getEth0Ip {
      local _ip _line
      while IFS=$': \t' read -a _line ;do
          [ -z "${_line%inet}" ] &&
            _ip=${_line[${#_line[1]}>4?1:2]} &&
            [ "${_ip#127.0.0.1}" ] && echo $_ip && return 0
        done< <(LANG=C /sbin/ifconfig eth0)
    }

    FLAG="/var/log/firstboot.log"
    if [ ! -f $FLAG ]; then

      IPADDRESS=$(getEth0Ip)

      # Create '/etc/consul/conf.d/client_connections.json'
      echo "{ \\"advertise_addr\\": \\"${IPADDRESS}\\", \\"bind_addr\\": \\"${IPADDRESS}\\" }"  > /etc/consul/conf.d/client_connections.json

      # Create '/etc/nomad-conf.d/client_connections.hcl'
      echo -e "bind_addr = \\"${IPADDRESS}\\"\\n advertise {\\n  http = \\"${IPADDRESS}\\"\\n  rpc = \\"${IPADDRESS}\\"\\n  serf = \\"${IPADDRESS}\\"\\n}"  > /etc/nomad-conf.d/client_connections.hcl

      if [ ! -d /mnt/dvd ]; then
        mkdir /mnt/dvd
      fi
      mount /dev/dvd /mnt/dvd

      # If the allow SSH file is not there, disable SSH in the firewall
      if [ ! -f /mnt/dvd/allow_ssh.json ]; then
        ufw deny 22
      fi

      # Copy '/etc/consul/conf.d/client_location.json'
      cp -a /mnt/dvd/consul_client_location.json /etc/consul/conf.d/client_location.json

      # Copy '/etc/consul/conf.d/client_secrets.json'
      cp -a /mnt/dvd/consul_client_secrets.json /etc/consul/conf.d/client_secrets.json

      # Copy '/etc/nomad-conf.d/client_location.json'
      cp -a /mnt/dvd/nomad_client_location.hcl /etc/nomad-conf.d/client_location.hcl

      # Copy '/etc/nomad-conf.d/client_secrets.json'
      cp -a /mnt/dvd/nomad_client_secrets.hcl /etc/nomad-conf.d/client_secrets.hcl

      # Copy the script that will be used to create the Docker IPVLAN network
      cp -a /mnt/dvd/docker_ipvlan.sh /tmp/docker_ipvlan.sh

      # Copy the dnsmasq configuration
      cp -a /mnt/dvd/dnsmasq/. /etc/dnsmasq.d/

      umount /dev/dvd

      # Run the script that creates the Docker IPVLAN network connection
      chmod a+x /tmp/docker_ipvlan.sh
      source /tmp/docker_ipvlan.sh

      sudo systemctl enable dnsmasq.service
      sudo systemctl restart dnsmasq.service

      sudo systemctl restart consul.service

      sudo systemctl enable nomad.service
      sudo systemctl restart nomad.service

      # The next line creates an empty file so it won't run the next boot
      touch $FLAG
    else
      echo "Provisioning script ran previously so nothing to do"
    fi
  BASH
  mode '755'
end

# Create the service that is going to run the script
file '/etc/systemd/system/provision.service' do
  action :create
  content <<~SYSTEMD
    [Unit]
    Description=Provision the environment
    Requires=network-online.target
    After=network-online.target

    [Service]
    Type=oneshot
    ExecStart=/etc/init.d/provision.sh
    RemainAfterExit=true

    [Install]
    WantedBy=network-online.target
  SYSTEMD
end

# Make sure the service starts on boot
service 'provision.service' do
  action [:enable]
end
