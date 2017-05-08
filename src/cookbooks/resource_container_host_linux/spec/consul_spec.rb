require 'spec_helper'

describe 'resource_container_host_linux::consul' do
  context 'configures consul' do
    let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

    it 'imports the consul recipe' do
      expect(chef_run).to include_recipe('consul::default')
    end
  end

  context 'configures the firewall for consul' do
    let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

    it 'opens the Consul HTTP port' do
      expect(chef_run).to create_firewall_rule('consul-http').with(
        values: [{
          command: 'allow',
          dest_port: 8500,
          direction: 'in'
        }]
      )
    end

    it 'opens the Consul serf LAN port' do
      expect(chef_run).to create_firewall_rule('consul-serf-lan').with(
        values: [{
          command: 'allow',
          dest_port: 8301,
          direction: 'in'
        }]
      )
    end

    it 'opens the Consul serf WAN port' do
      expect(chef_run).to create_firewall_rule('consul-serf-wan').with(
        values: [{
          command: 'allow',
          dest_port: 8302,
          direction: 'in'
        }]
      )
    end
  end
end
