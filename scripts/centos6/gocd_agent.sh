#!/bin/sh

yum install -y java-1.8.0-openjdk
yum install -y java-1.8.0-openjdk-devel
rpm -Uvh https://download.go.cd/binaries/16.2.1-3027/rpm/go-agent-16.2.1-3027.noarch.rpm

find_cloud_config=0

oldfile="/etc/cloud/cloud.cfg"
newfile="/etc/cloud/cloud.cfg.tmp"
rm -f $newfile

while IFS='' read -r line || [[ -n "$line" ]]; do
    if [[ $line =~ ^[:space:]. &&  $find_cloud_config ==  1 ]]
    then
      find_cloud_config=0
      echo -e " - openstack_gocd\n"  >> $newfile
      echo "$line" >> $newfile
    else
      echo "$line" >> $newfile
    fi
    if [[ $line =~ ^cloud_config_modules: ]]
    then
      find_cloud_config=1
    fi
done < $oldfile

mv -f $newfile $oldfile