#
# Cookbook Name:: resource_container_host_linux
# Recipe:: docker
#
# Copyright 2017, P. van der Velde
#

# Install the latest version of docker
docker_installation_package 'default' do
  version '1.13.0'
  action :create
  package_options "--force-yes -o Dpkg::Options::='--force-confold' -o Dpkg::Options::='--force-all'"
end

# Create the docker networks: macvlan bridge on the adapter that the host isn't using
# docker_network 'macvlan_bridge' do
#   driver 'macvlan'
#   action :create
# end
