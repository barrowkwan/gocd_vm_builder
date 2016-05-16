#!/bin/sh

cat << EOF1 > /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE="eth0"
BOOTPROTO="dhcp"
ONBOOT="yes"
TYPE="Ethernet"
USERCTL="yes"
PEERDNS="yes"
IPV6INIT="no"
PERSISTENT_DHCLIENT="1"
EOF1

/bin/cat << EOF  >> /etc/sysconfig/network
NOZEROCONF="yes"
EOF

/bin/rm -f /etc/udev/rules.d/70-persistent-net.rules

rm -f /etc/sysconfig/network-scripts/ifcfg-eno*

echo "# Override /lib/udev/rules.d/75-persistent-net-generator.rules" > /etc/udev/rules.d/75-persistent-net-generator.rules

cat << EOF > /etc/udev/rules.d/70-persistent-net.rules
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{type}=="1", KERNEL=="eth0", NAME="eth0"
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{type}=="1", KERNEL=="eth1", NAME="eth1"
EOF
