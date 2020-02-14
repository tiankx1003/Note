#!/bin/bash
if (($#<1))
then
    echo No Args
    exit
fi

#1. 改主机名/etc/sysconfig/network
sed -i "/^HOSTNAME/s/=.*/=hadoop$1/g" /etc/sysconfig/network

#2. 改网卡脚本/etc/udev/rules.d/70-persistent-net.rules
sed -i '/eth0/d' /etc/udev/rules.d/70-persistent-net.rules
sed -i '/eth1/s/eth1/eth0/g' /etc/udev/rules.d/70-persistent-net.rules
MAC=$(cat /etc/udev/rules.d/70-persistent-net.rules | grep eth0 | cut -d '"' -f 8)

#3. 改IP地址/etc/sysconfig/network-scripts/ifcfg-eth0
sed -i "/HWADDR/s/=.*/=$MAC/g" /etc/sysconfig/network-scripts/ifcfg-eth0
sed -i "/IPADDR/s/=.*/=192.168.6.$1/"  /etc/sysconfig/network-scripts/ifcfg-eth0
echo success!
reboot