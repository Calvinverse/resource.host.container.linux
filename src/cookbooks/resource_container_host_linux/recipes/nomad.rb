#
# Cookbook Name:: resource_container_host_linux
# Recipe:: nomad
#
# Copyright 2017, P. van der Velde
#


file "#{Nomad::Helpers::CONFIG_ROOT}/nomad_client.hcl" do
  action :create
  content <<-HCL
  atlas {
    join = false
  }

  client {
    enabled = true
    node_class = "linux"
    reserved {
      cpu            = 500
      disk           = 1024
      memory         = 512
      reserved_ports = "22,8300-8600"
    }
  }

  consul {
    address = "127.0.0.1:8500"
    auto_advertise = true
    client_auto_join = true
    server_auto_join = true
  }

  data_dir = "/var/lib/nomad"

  disable_update_check = true

  enable_syslog = true

  leave_on_interrupt = true
  leave_on_terminate = true

  log_level = "DEBUG"

  server {
    enabled = false
  }

  vault {
    enabled = false
  }
  HCL
end

file "#{Nomad::Helpers::CONFIG_ROOT}/nomad_client_connections.hcl" do
  action :create
  content <<-HCL
  bind_addr = "#{node['ipaddress']}"

  advertise {
    http = "#{node['ipaddress']}"
    rpc = "#{node['ipaddress']}"
    serf = "#{node['ipaddress']}"
  }
  HCL
end

file "#{Nomad::Helpers::CONFIG_ROOT}/nomad_client_location.hcl" do
  action :create
  content <<-HCL
  datacenter = "undefined"
  region = "global"
  HCL
end

#
# INSTALL NOMAD
#

# This installs nomad as follows
# - Binaries: /usr/local/bin/nomad
include_recipe 'nomad::install'

# Install the service that will run nomad
# Command line will be: nomad agent -config="#{Nomad::Helpers::CONFIG_ROOT}"
include_recipe 'nomad::manage'

#
# ALLOW NOMAD THROUGH THE FIREWALL
#

firewall_rule 'nomad-http' do
  command :allow
  description 'Allow Nomad HTTP traffic'
  dest_port 4646
  direction :in
end

firewall_rule 'nomad-rpc' do
  command :allow
  description 'Allow Nomad RCP traffic'
  dest_port 4647
  direction :in
end

firewall_rule 'nomad-serf' do
  command :allow
  description 'Allow Nomad Serf traffic'
  dest_port 4648
  direction :in
end

# Use consul-template to update the nomad configuration files
# consul_template 'nomad.json' do
#   backup true
#   command 'service name restart'
#   command_timeout '60s'
#   content <<-JSON
#   {
#     "template": {
#       "backup": true,
#       "command": "restart-service name",
#       "command_timeout": "60s",
#       "destination": "C:\\\\temp\\\\result",
#       "source": "C:\\\\Progam Files\\\\consul-template\\\\templates\\\\example.ctmpl"
#     }
#   }
#   JSON
#   destination default['nomad']['daemon_args']['config']
#   notifies :restart, 'consul_template_service[consul-template]', :delayed
#   perms '0440'
# end
