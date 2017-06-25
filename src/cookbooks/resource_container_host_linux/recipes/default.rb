# frozen_string_literal: true

#
# Cookbook Name:: resource_container_host_linux
# Recipe:: default
#
# Copyright 2017, P. van der Velde
#

#
# Configure the local resolver
#

include_recipe 'resolver::default'

#
# Include the local recipes
#

include_recipe 'resource_container_host_linux::firewall'
include_recipe 'resource_container_host_linux::consul'
include_recipe 'resource_container_host_linux::docker'
include_recipe 'resource_container_host_linux::network'
include_recipe 'resource_container_host_linux::nomad'
include_recipe 'resource_container_host_linux::provisioning'
