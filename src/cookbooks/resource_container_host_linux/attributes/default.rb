# frozen_string_literal: true

#
# CONSUL
#

default['consul']['version'] = '0.8.3'
default['consul']['config']['domain'] = 'consulverse'

# This is not a consul server node
default['consul']['config']['server'] = false

# For the time being don't verify incoming and outgoing TLS signatures
default['consul']['config']['verify_incoming'] = false
default['consul']['config']['verify_outgoing'] = false

# Bind the client address to the local host. The advertise and bind addresses
# will be set in a separate configuration file
default['consul']['config']['client_addr'] = '127.0.0.1'

# Disable remote exec
default['consul']['config']['disable_remote_exec'] = true

# Disable the update check
default['consul']['config']['disable_update_check'] = true

# Set the DNS configuration
default['consul']['config']['dns_config'] = {
  allow_stale: true,
  max_stale: '87600h',
  node_ttl: '10s',
  service_ttl: {
    '*': '10s'
  }
}

# Always leave the cluster if we are terminated
default['consul']['config']['leave_on_terminate'] = true

# Send all logs to syslog
default['consul']['config']['log_level'] = 'DEBUG'
default['consul']['config']['enable_syslog'] = true

default['consul']['config']['owner'] = 'root'

#
# DNSMASQ
#

# Never forward plain names (without a dot or domain part)
default['dnsmasq_local']['config']['domain_needed'] = true

# Never forward addresses in the non-routed address spaces.
default['dnsmasq_local']['config']['bogus_priv'] = true

# Disable negative caching
default['dnsmasq_local']['config']['no_negcache'] = true

# Normally responses which come from /etc/hosts and the DHCP lease
# file have Time-To-Live set as zero, which conventionally means
# do not cache further. If you are happy to trade lower load on the
# server for potentially stale date, you can set a time-to-live (in
# seconds) here.
default['dnsmasq_local']['config']['local_ttl'] = 10

# If you want dnsmasq to detect attempts by Verisign to send queries
# to unregistered .com and .net hosts to its sitefinder service and
# have dnsmasq instead return the correct NXDOMAIN response, uncomment
# this line. You can add similar lines to do the same for other
# registries which have implemented wildcard A records.
default['dnsmasq_local']['config']['bogus_nxdomain'] = '64.94.110.11'

# Include all the files in a directory except those ending in .dpkg-dist, dpkg-old and dpkg-new
default['dnsmasq_local']['config']['conf_dir'] = '/etc/dnsmasq.d,.dpkg-dist,.dpkg-old,.dpkg-new'

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

#
# PROVISIONING
#

#
# RESOLVER
#

default['resolver']['nameservers'] = ['127.0.0.1', '8.8.8.8']
