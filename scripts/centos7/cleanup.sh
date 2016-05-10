#!/bin/sh

/bin/sed -i 's|\(^PasswordAuthentication \)yes|\1no|' /etc/ssh/sshd_config
/bin/sed -i 's|\(^PermitRootLogin \)yes|\1no|' /etc/ssh/sshd_config

/usr/bin/yum clean all
/bin/rm -rf /var/log/yum.log
/bin/rm -rf /var/lib/yum/*
/bin/rm -rf /root/install.log
/bin/rm -rf /root/install.log.syslog
/bin/rm -rf /root/anaconda-ks.cfg
/bin/rm -rf /var/log/anaconda*
/bin/rm -rf /tmp/*
/bin/rm -rf /etc/yum.repos.d/CentOS*

rm -f /var/log/wtmp /var/log/btmp

history -c
