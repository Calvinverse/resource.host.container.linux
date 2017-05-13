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

# Bind the client address to the local host. The advertise and bind addresses
# will be set in a separate configuration file
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
