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
        package_version: '5:20.10.7~3-0~ubuntu-bionic'
      )
    end
  end

  context 'set the interface to allow all packets through' do
    let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

    interface_content = <<~SCRIPT
      # This file describes the network interfaces available on your system
      # and how to activate them. For more information, see interfaces(5).

      source /etc/network/interfaces.d/*

      # The loopback network interface
      auto lo
      iface lo inet loopback

      # The primary network interface
      auto eth0
      iface eth0 inet dhcp

      # The secundary network interface. This one is used by docker
      auto eth1
      iface eth1 inet dhcp
          pre-up sleep 2
          up ifconfig eth1 promisc on
          down ifconfig eth1 promisc off
    SCRIPT
    it 'creates /etc/network/interfaces' do
      expect(chef_run).to create_file('/etc/network/interfaces')
        .with_content(interface_content)
    end
  end
end
