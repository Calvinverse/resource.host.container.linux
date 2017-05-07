require 'spec_helper'

describe 'resource_container_host_linux::consul' do
  context 'configures consul' do
    let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

    # settings
    it 'disables server mode' do
      expect(node['consul']['config']['server']).to eq(false)
    end

    it 'disables TLS verification' do
      expect(node['consul']['config']['verify_incoming']).to eq(false)
      expect(node['consul']['config']['verify_outgoing']).to eq(false)
    end

    it 'sets the encryption flags to empty' do
      expect(node['consul']['config']['ca_file']).to eq('')
      expect(node['consul']['config']['cert_file']).to eq('')
      expect(node['consul']['config']['key_file']).to eq('')
    end

    it 'sets the client address to localhost' do
      expect(node['consul']['config']['client_addr']).to eq('127.0.0.1')
    end

    it 'disables remote exec' do
      expect(node['consul']['config']['disable_remote_exec']).to eq(true)
    end

    it 'disables the update check' do
      expect(node['consul']['config']['disable_update_check']).to eq(true)
    end

    it 'sets consul to leave the cluster when terminated' do
      expect(node['consul']['config']['leave_on_terminate']).to eq(true)
    end

    it 'sets the appropriate log settings' do
      expect(node['consul']['config']['log_level']).to eq('DEBUG')
      expect(node['consul']['config']['enable_syslog']).to eq(true)
    end

    it 'sets the domain for Calvinverse' do
      expect(node['consul']['config']['domain']).to eq('consulverse')
    end

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
