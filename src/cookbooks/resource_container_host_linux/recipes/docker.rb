# frozen_string_literal: true

#
# Cookbook Name:: resource_container_host_linux
# Recipe:: docker
#
# Copyright 2017, P. van der Velde
#

include_recipe 'chef-apt-docker::default'

# Make docker run in experimental mode so that we have the ipvlan network driver
file '/etc/docker/daemon.json' do
  action :create
  content <<~JSON
    {
        "experimental": true
    }
  JSON
end

# Install the latest version of docker
docker_installation_package 'default' do
  action :create
  package_name 'docker-engine'
  package_options "--force-yes -o Dpkg::Options::='--force-confold' -o Dpkg::Options::='--force-all'"
  version '17.05.0'
end

# Create the ipvlan network. Link to ETH0. Do this at provisioning time because we need to set the
# IP-address range to be 192.168.x.0/24 where x depends on the host

# Need to provide some way to route the ipvlan network so that it knows about the outside world
# and the outside world knows about it -> BGP (e.g. https://github.com/osrg/gobgp)
