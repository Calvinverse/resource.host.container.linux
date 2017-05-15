# frozen_string_literal: true

#
# Cookbook Name:: resource_container_host_linux
# Recipe:: docker
#
# Copyright 2017, P. van der Velde
#

include_recipe 'chef-apt-docker::default'

# Install the latest version of docker
docker_installation_package 'default' do
  action :create
  package_name 'docker-engine'
  package_options "--force-yes -o Dpkg::Options::='--force-confold' -o Dpkg::Options::='--force-all'"
  version '1.13.0'
end

# Create the docker networks: macvlan bridge
docker_network 'macvlan_bridge' do
  action :create
  driver 'macvlan'
  gateway '192.168.7.1'
  ip_range '192.168.7.128/25'
  subnet ['192.168.7.0/24']
end
