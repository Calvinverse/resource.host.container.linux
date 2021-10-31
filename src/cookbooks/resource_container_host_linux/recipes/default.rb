# frozen_string_literal: true

#
# Cookbook Name:: resource_container_host_linux
# Recipe:: default
#
# Copyright 2017, P. van der Velde
#

# Always make sure that apt is up to date
apt_update 'update' do
  action :update
end

#
# Include the local recipes
#

include_recipe 'resource_container_host_linux::firewall'

include_recipe 'resource_container_host_linux::consul'
include_recipe 'resource_container_host_linux::docker'
include_recipe 'resource_container_host_linux::meta'
include_recipe 'resource_container_host_linux::nomad'
include_recipe 'resource_container_host_linux::provisioning'
