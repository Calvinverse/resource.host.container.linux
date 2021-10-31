# frozen_string_literal: true

#
# Cookbook Name:: resource_container_host_linux
# Recipe:: consul
#
# Copyright 2021, P. van der Velde
#

# Overwrite the consul service configuration because we need another command line parameter
# to set the bind interface given that we have multiple network interfaces (eth0 + the docker interfaces)
# (see: https://www.consul.io/docs/agent/options#_bind)
systemd_service 'consul' do
  action :create
  install do
    wanted_by %w[multi-user.target]
  end
  service do
    environment '"GOMAXPROCS=2" "PATH=/usr/local/bin:/usr/bin:/bin"'
    exec_reload '/bin/kill -HUP $MAINPID'
    exec_start "/opt/consul/1.9.5/consul agent -config-file=/etc/consul/consul.json -config-dir=/etc/consul/conf.d -bind='{{ GetInterfaceIP \"eth0\" }}'"
    kill_signal 'TERM'
    restart 'always'
    restart_sec 5
    user 'consul'
    working_directory '/var/lib/consul'
  end
  unit do
    after %w[network.target]
    description 'consul'
    start_limit_interval_sec 0
    wants %w[network.target]
  end
end
