# frozen_string_literal: true

require 'spec_helper'

describe 'resource_container_host_linux::nomad' do
  context 'creates the nomad configuration files' do
    let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

    nomad_client_config_content = <<~HCL
      atlas {
        join = false
      }

      client {
        enabled = true
        meta {
        }
        reserved {
          cpu            = 500
          disk           = 1024
          memory         = 512
          reserved_ports = "22,53,8300-8600"
        }
      }

      consul {
        address = "127.0.0.1:8500"
        auto_advertise = true
        client_auto_join = true
        server_auto_join = true
      }

      data_dir = "/srv/containers/nomad/data"

      disable_update_check = true

      enable_syslog = true

      leave_on_interrupt = true
      leave_on_terminate = true

      log_level = "INFO"

      server {
        enabled = false
      }

      vault {
        enabled = false
      }
    HCL
    it 'creates client.hcl in the nomad configuration directory' do
      expect(chef_run).to create_file('/etc/nomad-conf.d/client.hcl')
        .with_content(nomad_client_config_content)
    end
  end

  context 'configures nomad' do
    let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }
    it 'installs the nomad binaries' do
      expect(chef_run).to include_recipe('nomad::install')
    end

    it 'installs the nomad service' do
      expect(chef_run).to create_systemd_service('nomad').with(
        action: [:create],
        after: %w[network-online.target],
        description: 'Nomad System Scheduler',
        documentation: 'https://nomadproject.io/docs/index.html',
        requires: %w[network-online.target]
      )
    end

    it 'disables the nomad service' do
      expect(chef_run).to disable_service('nomad')
    end
  end

  context 'configures the firewall for nomad' do
    let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

    it 'opens the Nomad HTTP port' do
      expect(chef_run).to create_firewall_rule('nomad-http').with(
        command: :allow,
        dest_port: 4646,
        direction: :in
      )
    end

    it 'opens the Nomad serf LAN port' do
      expect(chef_run).to create_firewall_rule('nomad-rpc').with(
        command: :allow,
        dest_port: 4647,
        direction: :in
      )
    end

    it 'opens the Nomad serf WAN port' do
      expect(chef_run).to create_firewall_rule('nomad-serf').with(
        command: :allow,
        dest_port: 4648,
        direction: :in
      )
    end
  end
end
