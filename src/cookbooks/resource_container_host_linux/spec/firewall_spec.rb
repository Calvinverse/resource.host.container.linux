require 'spec_helper'

describe 'resource_container_host_linux::firewall' do
  context 'configures the firewall' do
    let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

    it 'installs the default firewall' do
      expect(chef_run).to install_firewall('default')
    end
  end
end
