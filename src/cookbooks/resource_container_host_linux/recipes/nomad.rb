#
# Cookbook Name:: resource_container_host_linux
# Recipe:: nomad
#
# Copyright 2017, P. van der Velde
#

nomad_config 'nomad_config.json' do
  data_dir ''
  leave_on_interrupt true
  leave_on_terminate true
  region 'global'
end

nomad_client_config 'nomad_client.json' do
  enabled true
end

nomad_consul_config 'nomad_consul.json' do
  address '127.0.0.1:8500'
  auto_advertise true
  client_auto_join true
  server_auto_join true
  verify_ssl false
end

include_recipe 'nomad::default'

# Use consul-template to update the nomad configuration files
consul_template 'nomad.json' do
  backup true
  command 'service name restart'
  command_timeout '60s'
  content <<-JSON
  {
    "template": {
      "backup": true,
      "command": "restart-service name",
      "command_timeout": "60s",
      "destination": "C:\\\\temp\\\\result",
      "source": "C:\\\\Progam Files\\\\consul-template\\\\templates\\\\example.ctmpl"
    }
  }
  JSON
  destination default['nomad']['daemon_args']['config']
  notifies :restart, 'consul_template_service[consul-template]', :delayed
  perms '0440'
end
