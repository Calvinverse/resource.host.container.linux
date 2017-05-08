require 'spec_helper'

describe 'resource_container_host_linux::nomad' do
  context 'creates the nomad configuration files' do
    let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

    nomad_client_config_content = <<-HCL
  atlas {
    join = false
  }

  client {
    enabled = true
    node_class = "linux"
    reserved {
      cpu            = 500
      disk           = 1024
      memory         = 512
      reserved_ports = "22,8300-8600"
    }
  }

  consul {
    address = "127.0.0.1:8500"
    auto_advertise = true
    client_auto_join = true
    server_auto_join = true
  }

  data_dir = "/var/lib/nomad"

  disable_update_check = true

  enable_syslog = true

  leave_on_interrupt = true
  leave_on_terminate = true

  log_level = "DEBUG"

  server {
    enabled = false
  }

  vault {
    enabled = false
  }
    HCL
    it 'creates nomad_client.hcl in the nomad configuration directory' do
      expect(chef_run).to create_file('/etc/nomad-conf.d/nomad_client.hcl')
        .with_content(nomad_client_config_content)
    end

    nomad_client_connection_config_content = <<-HCL
  bind_addr = "10.0.0.2"

  advertise {
    http = "10.0.0.2"
    rpc = "10.0.0.2"
    serf = "10.0.0.2"
  }
    HCL
    it 'creates nomad_client_connections.hcl in the nomad configuration directory' do
      expect(chef_run).to create_file('/etc/nomad-conf.d/nomad_client_connections.hcl')
        .with_content(nomad_client_connection_config_content)
    end

    nomad_client_location_config_content = <<-HCL
  datacenter = "undefined"
  region = "global"
    HCL
    it 'creates nomad_client_location.hcl in the nomad configuration directory' do
      expect(chef_run).to create_file('/etc/nomad-conf.d/nomad_client_location.hcl')
        .with_content(nomad_client_location_config_content)
    end
  end

  context 'configures nomad' do
    let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }
    it 'installs the nomad binaries' do
      expect(chef_run).to include_recipe('nomad::install')
    end

    it 'installs the nomad service' do
      expect(chef_run).to include_recipe('nomad::manage')
    end
  end

  context 'configures the firewall for nomad' do
    let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

    it 'opens the Nomad HTTP port' do
      expect(chef_run).to create_firewall_rule('nomad-http').with(
        values: [{
          command: 'allow',
          dest_port: 4646,
          direction: 'in'
        }]
      )
    end

    it 'opens the Nomad serf LAN port' do
      expect(chef_run).to create_firewall_rule('nomad-rpc').with(
        values: [{
          command: 'allow',
          dest_port: 4647,
          direction: 'in'
        }]
      )
    end

    it 'opens the Nomad serf WAN port' do
      expect(chef_run).to create_firewall_rule('nomad-serf').with(
        values: [{
          command: 'allow',
          dest_port: 4648,
          direction: 'in'
        }]
      )
    end
  end
end
