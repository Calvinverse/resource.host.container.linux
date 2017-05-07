require 'spec_helper'

describe 'resource_container_host_linux::docker' do
  context 'configures docker' do
    it 'installs docker' do
      expect(chef_run).to create_docker_installation_package('default').with(
        values: [{
          action: 'create',
          package_name: 'docker-engine',
          package_options: "--force-yes -o Dpkg::Options::='--force-confold' -o Dpkg::Options::='--force-all'",
          version: '1.13.0'
        }]
      )
    end
  end
end
