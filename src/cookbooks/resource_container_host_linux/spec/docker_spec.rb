# frozen_string_literal: true

require 'spec_helper'

describe 'resource_container_host_linux::docker' do
  context 'configures docker' do
    let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

    it 'installs docker' do
      expect(chef_run).to create_docker_installation_package('default').with(
        action: [:create],
        package_name: 'docker-ce',
        package_options: "--force-yes -o Dpkg::Options::='--force-confold' -o Dpkg::Options::='--force-all'",
        version: '17.09.0'
      )
    end
  end

  context 'set the interface to allow all packets through' do
    let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

    interface_content = <<~SCRIPT
      up /sbin/ifconfig eth0 promisc on
    SCRIPT
    it 'creates /etc/network/interface' do
      expect(chef_run).to create_file('/etc/network/interface')
        .with_content(interface_content)
    end
  end
end
