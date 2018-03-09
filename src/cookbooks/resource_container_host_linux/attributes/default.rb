# frozen_string_literal: true

#
# CONSULTEMPLATE
#

default['consul_template']['config_path'] = '/etc/consul-template.d/conf'
default['consul_template']['template_path'] = '/etc/consul-template.d/templates'



#
# FIREWALL
#

# Allow communication on the loopback address (127.0.0.1 and ::1)
default['firewall']['allow_loopback'] = true

# Do not allow MOSH connections
default['firewall']['allow_mosh'] = false

# Do not allow WinRM (which wouldn't work on Linux anyway, but close the ports just to be sure)
default['firewall']['allow_winrm'] = false

# No communication via IPv6 at all
default['firewall']['ipv6_enabled'] = false

#
# NOMAD
#

default['nomad']['package'] = '0.7.1/nomad_0.7.1_linux_amd64.zip'
default['nomad']['checksum'] = '72b32799c2128ed9d2bb6cbf00c7600644a8d06c521a320e42d5493a5d8a789a'

default['nomad']['service_user'] = 'nomad'
default['nomad']['service_group'] = 'nomad'

default['nomad']['consul_template_metrics_file'] = 'nomad_metrics.ctmpl'
default['nomad']['consul_template_region_file'] = 'nomad_region.ctmpl'
default['nomad']['consul_template_secrets_file'] = 'nomad_secrets.ctmpl'
default['nomad']['consul_template_server_file'] = 'nomad_server.ctmpl'

default['nomad']['metrics_file'] = 'metrics.hcl'
default['nomad']['region_file'] = 'region.hcl'
default['nomad']['secrets_file'] = 'secrets.hcl'
default['nomad']['server_file'] = 'server.hcl'
