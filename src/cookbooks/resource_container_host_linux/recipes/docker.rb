# frozen_string_literal: true

#
# Cookbook Name:: resource_container_host_linux
# Recipe:: docker
#
# Copyright 2017, P. van der Velde
#

include_recipe 'chef-apt-docker::default'

directory '/etc/docker' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

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
  package_name 'docker-ce'
  package_options "--force-yes -o Dpkg::Options::='--force-confold' -o Dpkg::Options::='--force-all'"
  version '17.09.0'
end

#
# UPDATE THE NETWORK INTERFACE
#

# Turn on promiscuous mode so that all packets for all MAC addresses are processed, including
# the ones for the docker containers
file '/etc/network/interfaces' do
  action :create
  content <<~SCRIPT
    # This file describes the network interfaces available on your system
    # and how to activate them. For more information, see interfaces(5).

    source /etc/network/interfaces.d/*

    # The loopback network interface
    auto lo
    iface lo inet loopback

    # The primary network interface
    auto eth0
    iface eth0 inet dhcp
        pre-up sleep 2
        up ifconfig eth0 promisc on
        down ifconfig eth0 promisc off
  SCRIPT
end

# The docker network is set in the provisioning step because we need to set the IP range to something
# sensible
