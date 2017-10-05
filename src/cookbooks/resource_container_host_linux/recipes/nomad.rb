# frozen_string_literal: true

#
# Cookbook Name:: resource_container_host_linux
# Recipe:: nomad
#
# Copyright 2017, P. van der Velde
#

directory Nomad::Helpers::CONFIG_ROOT.to_s do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

file "#{Nomad::Helpers::CONFIG_ROOT}/client.hcl" do
  action :create
  content <<~HCL
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

    log_level = "INFO"

    server {
      enabled = false
    }

    vault {
      enabled = false
    }
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
args = Nomad::Helpers.hash_to_arg_string(node['nomad']['daemon_args'])

# Create the systemd service for nomad. Set it to depend on the network being up
# so that it won't start unless the network stack is initialized and has an
# IP address
systemd_service 'nomad' do
  action :create
  after %w[network-online.target]
  description 'Nomad System Scheduler'
  documentation 'https://nomadproject.io/docs/index.html'
  install do
    wanted_by %w[multi-user.target]
  end
  service do
    exec_start "/usr/local/bin/nomad agent #{args}"
    restart 'on-failure'
  end
  requires %w[network-online.target]
end

# Make sure the nomad service doesn't start automatically. This will be changed
# after we have provisioned the box
service 'nomad' do
  action :disable
end

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
