# frozen_string_literal: true

#
# Cookbook Name:: resource_container_host_linux
# Recipe:: consul
#
# Copyright 2017, P. van der Velde
#

# Configure the service user under which consul will be run
poise_service_user node['consul']['service_user'] do
  group node['consul']['service_group']
end

node.default['consul']['version'] = '0.8.1'

#
# GENERIC CONSUL CONFIGURATION
#

# This is not a consul server node
node.default['consul']['config']['server'] = false

# For the time being don't verify incoming and outgoing TLS signatures
node.default['consul']['config']['verify_incoming'] = false
node.default['consul']['config']['verify_outgoing'] = false

# Don't set any values for the encryption values. They will be set in a separate
# configuration file
node.default['consul']['config']['ca_file'] = ''
node.default['consul']['config']['cert_file'] = ''
node.default['consul']['config']['key_file'] = ''

# Bind the client address to the local host. The advertise and bind addresses
# will be set in a separate configuration file
node.default['consul']['config']['advertise_addr'] = ''
node.default['consul']['config']['bind_addr'] = ''
node.default['consul']['config']['client_addr'] = '127.0.0.1'

# Disable remote exec
node.default['consul']['config']['disable_remote_exec'] = true

# Disable the update check
node.default['consul']['config']['disable_update_check'] = true

# Always leave the cluster if we are terminated
node.default['consul']['config']['leave_on_terminate'] = true

# Send all logs to syslog
node.default['consul']['config']['log_level'] = 'DEBUG'
node.default['consul']['config']['enable_syslog'] = true

#
# ENVIRONMENT CONFIGURATION
#

# Set the domain
node.default['consul']['config']['domain'] = 'consulverse'

#
# INSTALL CONSUL
#

# This installs consul as follows
# - Binaries: /usr/local/bin/consul
# - Configuration: /etc/consul.json and /etc/consul/conf.d
include_recipe 'consul::default'

# Make the consul config file be owned by root so that it cannot be changed easily
consul_config '/etc/consul/consul.json' do
  owner 'root'
end

#
# ALLOW CONSUL THROUGH THE FIREWALL
#

firewall_rule 'consul-http' do
  command :allow
  description 'Allow Consul HTTP traffic'
  dest_port 8500
  direction :in
end

firewall_rule 'consul-serf-lan' do
  command :allow
  description 'Allow Consul serf LAN traffic'
  dest_port 8301
  direction :in
end

firewall_rule 'consul-serf-wan' do
  command :allow
  description 'Allow Consul serf WAN traffic'
  dest_port 8302
  direction :in
end

# Install Consul template

# Configure the provisioning script
file '/etc/init.d/provision.sh' do
  action :create
  content <<~BASH
    #!/bin/bash

    FLAG="/var/log/firstboot.log"
    if [ ! -f $FLAG ]; then
      mount /dev/cdrom /mnt/cdrom

      # If the allow SSH file is not there, disable SSH in the firewall
      if [ ! -f /mnt/cdrom/allow_ssh.json ]; then
        ufw deny 22
      fi

      # Update '/etc/consul/conf.d/client_location.json'
      cp /mnt/cdrom/client_location.json /etc/consul/conf.d/client_location.json

      # Update '/etc/consul/conf.d/client_connections.json'
      cp /mnt/cdrom/client_connections.json /etc/consul/conf.d/client_connections.json

      # Update or delete '/etc/consul/conf.d/client_secrets.json'
      cp /mnt/cdrom/client_secrets.json /etc/consul/conf.d/client_secrets.json

      umount /dev/cdrom

      sudo systemctl restart consul.service

      # The next line creates an empty file so it won't run the next boot
      touch $FLAG
    else
      echo "Provisioning script ran previously so nothing to do"
    fi
  BASH
  mode '755'
end
