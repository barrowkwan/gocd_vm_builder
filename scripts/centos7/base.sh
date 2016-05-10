#!/bin/sh


# timezone above in this kickstart script did not work.
/usr/bin/timedatectl set-timezone America/Los_Angeles

/bin/echo 'UseDNS no' >> /etc/ssh/sshd_config
sed -i -- 's/PermitRootLogin/#PermitRootLogin/g' /etc/ssh/sshd_config


echo "RUN_FIRSTBOOT=NO" > /etc/sysconfig/firstboot

/bin/sed -i 's/crashkernel=auto//g' /etc/grub2.cfg

#setup getty on ttyS0
echo "ttyS0" >> /etc/securetty
mkdir /etc/init
cat <<EOF > /etc/init/ttyS0.conf
start on stopped rc RUNLEVEL=[2345]
stop on starting runlevel [016]
respawn
instance /dev/ttyS0
exec /sbin/agetty /dev/ttyS0 115200 vt100-nav
EOF

/bin/sed -i 's|\(^PasswordAuthentication \)no|\1yes|' /etc/ssh/sshd_config




