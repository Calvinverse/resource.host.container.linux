#!/bin/bash

# Return the subnet as a string. This is used to create a docker network with the given
# subnet.
function f_getContainerSubnet {
    echo '192.168.101.0/24'
}

# Return the VLAN tag as a string.
function f_getVlanTag {
    echo '1010'
}
