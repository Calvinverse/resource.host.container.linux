require 'spec_helper'

describe 'resource_container_host_linux::firewall' do
  context 'configures the firewall' do
    let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

    it 'allows loopback' do
      expect(node['firewall']['allow_loopback']).to eq(true)
    end

    it 'allows ssh' do
      expect(node['firewall']['allow_ssh']).to eq(true)
    end

    it 'does not allow mosh' do
      expect(node['firewall']['allow_mosh']).to eq(false)
    end

    it 'does not allow winrm' do
      expect(node['firewall']['allow_winrm']).to eq(false)
    end

    it 'disables ipv6' do
      expect(node['firewall']['ipv6_enabled']).to eq(false)
    end

    it 'installs the default firewall' do
      expect(chef_run).to install_firewall('default')
    end
  end
end
