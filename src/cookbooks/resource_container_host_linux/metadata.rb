# frozen_string_literal: true

chef_version '>= 12.5' if respond_to?(:chef_version)
description 'Environment cookbook that configures a Linux server as a container host with consul and nomad'
issues_url '${ProductUrl}/issues' if respond_to?(:issues_url)
license 'Apache-2.0'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
name 'resource_container_host_linux'
maintainer '${CompanyName} (${CompanyUrl})'
maintainer_email '${EmailDocumentation}'
source_url '${ProductUrl}' if respond_to?(:source_url)
version '${VersionSemantic}'

supports 'ubuntu', '>= 16.04'

depends 'chef-apt-docker', '= 1.1.1'
depends 'consul', '= 3.0.0'
depends 'docker', '= 2.15.6'
depends 'firewall', '= 2.6.1'
depends 'nomad', '= 0.12.0'
depends 'systemd', '= 2.1.3'