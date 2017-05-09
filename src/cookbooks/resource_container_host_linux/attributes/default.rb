# frozen_string_literal: true

# Nomad
# Default daemon configuration
default['nomad']['daemon_args'].tap do |da|
  # da['dev'] = nil
  # da['network-interface'] = node['network']['default_interface']
end
