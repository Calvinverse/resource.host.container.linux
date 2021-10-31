# frozen_string_literal: true

require 'spec_helper'

describe 'resource_container_host_linux::consul' do
  context 'configures the consul bind address' do
    let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

    it 'updates the consul service definition' do
      expect(chef_run).to create_systemd_service('consul').with(
        action: [:create],
        service_exec_start: "/opt/consul/1.9.5/consul agent -config-file=/etc/consul/consul.json -config-dir=/etc/consul/conf.d -bind='{{ GetInterfaceIP \"eth0\" }}'",
        service_restart: 'always',
        service_restart_sec: 5,
        unit_after: %w[network.target],
        unit_description: 'consul',
        unit_wants: %w[network.target],
        unit_start_limit_interval_sec: 0
      )
    end
  end
end
