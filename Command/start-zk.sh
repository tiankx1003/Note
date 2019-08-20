#!/bin/bash
for i in `cat /opt/module/hadoop-2.7.2/etc/hadoop/slaves`
do
    ssh $i 'source /etc/profile&&zkServer.sh start'
done