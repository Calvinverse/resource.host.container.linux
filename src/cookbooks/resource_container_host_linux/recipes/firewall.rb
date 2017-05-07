#
# Cookbook Name:: resource_container_host_linux
# Recipe:: firewall
#
# Copyright 2017, P. van der Velde
#

# Allow communication on the loopback address (127.0.0.1 and ::1)
node.default['firewall']['allow_loopback'] = true

# Allow SSH connections
node.default['firewall']['allow_ssh'] = true

# Do not allow MOSH connections
node.default['firewall']['allow_mosh'] = false

# Do not allow WinRM (which wouldn't work on Linux anyway, but close the ports just to be sure)
node.default['firewall']['allow_winrm'] = false

# No communication via IPv6 at all
node.default['firewall']['ipv6_enabled'] = false

firewall 'default' do
  action :install
end
