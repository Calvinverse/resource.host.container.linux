# frozen_string_literal: true

#
# Cookbook Name:: resource_container_host_linux
# Recipe:: network
#
# Copyright 2017, P. van der Velde
#

#
# Configure the local resolver
#

include_recipe 'resolver::default'

#
# Configure DNSMasq
#

# the local configuration will be created upon provisioning because we need to know
# the IP addresses for the local DNS servers

# Install the application
dnsmasq_local_app 'default' do
  action :install
end

# setup the dnsmasq service
dnsmasq_local_service 'default' do
  action %i[create disable]
end

#
# Configure BPG
#

# Create the systemd service for gobgpd. Set it to depend on the network being up
# so that it won't start unless the network stack is initialized and has an
# IP address
systemd_service 'gobgp' do
  action :create
  after %w[network-online.target]
  description 'GoBGP'
  documentation 'https://github.com/osrg/gobgp'
  install do
    wanted_by %w[multi-user.target]
  end
  service do
    exec_start '/usr/local/bin/gobgp -f /etc/gobgp/gobgpd.conf -t yaml --cpus=2'
    restart 'on-failure'
  end
  requires %w[network-online.target]
end

# Make sure the gobgpd service doesn't start automatically. This will be changed
# after we have provisioned the box
service 'gobgp' do
  action :disable
end
