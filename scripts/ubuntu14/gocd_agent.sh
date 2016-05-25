#!/bin/sh

apt-get install openjdk-8-jdk
wget -O /tmp https://download.go.cd/binaries/16.5.0-3305/deb/go-agent-16.5.0-3305.deb
cd /tmp
dpkg -i go-agent-16.5.0-3305.deb
rm -f /tmp/go-agent-16.5.0-3305.deb

