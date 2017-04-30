#
# Cookbook Name:: resource_container_host_linux
# Recipe:: default
#
# Copyright 2017, P. van der Velde
#

include_recipe 'resource_container_host_linux::consul'
include_recipe 'resource_container_host_linux::docker'
include_recipe 'resource_container_host_linux::nomad'
