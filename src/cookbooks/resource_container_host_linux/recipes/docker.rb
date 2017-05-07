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

# Create the docker networks: macvlan bridge on the adapter that the host isn't using
# docker_network 'macvlan_bridge' do
#   driver 'macvlan'
#   action :create
# end
