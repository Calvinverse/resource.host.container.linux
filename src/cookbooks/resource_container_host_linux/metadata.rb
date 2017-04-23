name 'resource_container_host_linux'
maintainer '${CompanyName} (${CompanyUrl})'
maintainer_email '${EmailDocumentation}'
license 'Apache v2.0'
description 'Environment cookbook that configures a Linux server as a container host with consul and nomad'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version '1.0.0'

supports 'ubuntu', '>= 16.04'

depends 'consul', '>= 2.3.0'
depends 'docker', '>= 2.15.5'
depends 'nomad', '>= 0.12.0'
