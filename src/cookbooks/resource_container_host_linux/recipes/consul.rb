#
# Cookbook Name:: resource_container_host_linux
# Recipe:: consul
#
# Copyright 2017, P. van der Velde
#

# Install Consul
poise_service_user node['consul']['service_user'] do
  group node['consul']['service_group']
end

node.default['consul']['version'] = '0.8.1'
node.default['consul']['config']['server'] = false
node.default['consul']['config']['verify_incoming'] = false
node.default['consul']['config']['verify_outgoing'] = false
node.default['consul']['config']['bind_addr'] = node['ipaddress']
node.default['consul']['config']['advertise_addr'] = node['ipaddress']
node.default['consul']['config']['start_join'] = %w[undefined undefined undefined]
include_recipe 'consul::default'

# Delay start?

# Install Consul template

# Provisioning
