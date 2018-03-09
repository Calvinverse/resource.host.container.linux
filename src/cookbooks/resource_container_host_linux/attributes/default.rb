# frozen_string_literal: true

#
#




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



