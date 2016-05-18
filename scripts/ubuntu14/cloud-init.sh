#!bin/sh

/bin/sed -i 's/name: fedora/name: gocd/' /etc/cloud/cloud.cfg
/bin/sed -i 's/name: centos/name: gocd/' /etc/cloud/cloud.cfg
/bin/sed -i 's/distro: fedora/distro: rhel/' /etc/cloud/cloud.cfg
/bin/sed -i 's/gecos: Fedora Cloud User/gecos: GoCD/' /etc/cloud/cloud.cfg
/bin/sed -i 's/gecos: Cloud User/gecos: GoCD/' /etc/cloud/cloud.cfg
#/bin/sed -i '/- phone-home/d' /etc/cloud/cloud.cfg
/bin/sed -i '/^ssh_pwauth/c ssh_pwauth: 0' /etc/cloud/cloud.cfg
/bin/sed -i '/^disable_root/c disable_root: 1' /etc/cloud/cloud.cfg



