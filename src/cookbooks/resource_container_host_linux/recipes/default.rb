#
# Cookbook Name:: resource_container_host_linux
# Recipe:: default
#
# Copyright 2017, P. van der Velde
#

# Configure the network interfaces, there should be two, one for the host and one for the containers

# Create the docker networks: macvlan bridge on the adapter that the host isn't using
docker_installation_package 'default' do
  version '1.8.3'
  action :create
  package_options "--force-yes -o Dpkg::Options::='--force-confold' -o Dpkg::Options::='--force-all'" # if Ubuntu for example
end

docker_network 'macvlan_bridge' do
  driver 'macvlan'
  action :create
end

# Install Consul
poise_service_user node['consul']['service_user'] do
  group node['consul']['service_group']
end

node.default['consul']['config']['server'] = false
node.default['consul']['config']['verify_incoming'] = false
node.default['consul']['config']['verify_outgoing'] = false
node.default['consul']['config']['bind_addr'] = node['ipaddress']
node.default['consul']['config']['advertise_addr'] = node['ipaddress']
include_recipe 'consul::default'

# Install Nomad
nomad_config '' do
  region 'global'
  datacenter 'undefined'
  data_dir ''
  log_level ''
  bind_addr node['ipaddress']
  enable_debug false
  leave_on_interrupt true
  leave_on_terminate true
  enable_syslog false
  syslog_facility ''
  disable_update_check true
end

nomad_client_config '' do
  enabled true
  servers %w[
    undefined
    undefined
    undefined
  ]
  node_id 'undefined'
  node_class 'undefined'
  meta [{
    owner: 'undefined'
  }]
  options [{}]
  network_interface 'eth1'
  max_kill_timeout ''
  reserved [{
    cpu: 10,
    memory: 10,
    disk: 10,
    reserved_ports: '8500-8600'
  }]
end

nomad_consul_config '' do
  address '127.0.0.1:8500'
  auto_advertise false
  client_auto_join false
  server_auto_join false
  verify_ssl false
end

nomad_vault_config '' do
  enabled false
end

include_recipe 'nomad::default'

# install consul template
# Set it to update the nomad configuration files when updated and (re)start nomad

# Install the provisioning tool
