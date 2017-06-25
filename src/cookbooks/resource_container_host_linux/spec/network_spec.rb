# frozen_string_literal: true

require 'spec_helper'

describe 'resource_container_host_linux::network' do
  context 'installs dnsmasq' do
    let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

    it 'installs the dnsmasq binaries' do
      expect(chef_run).to install_dnsmasq_local_app('default')
    end

    it 'creates the default dnsmasq configuration' do
      expect(chef_run).to create_dnsmasq_local_config('default')
    end

    it 'configures dnsmasq as a service' do
      expect(chef_run).to create_dnsmasq_local_service('default')
    end
  end

  context 'configures bgp' do
    let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

    it 'installs the gobgp service' do
      expect(chef_run).to create_systemd_service('gobgp').with(
        action: [:create],
        after: %w[network-online.target],
        description: 'GoBGP',
        documentation: 'https://github.com/osrg/gobgp',
        requires: %w[network-online.target]
      )
    end

    it 'disables the bgp service' do
      expect(chef_run).to disable_service('gobgp')
    end
  end
end
