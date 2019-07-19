#!/bin/bash
i=1
s=0
while [ $i -le 100 ]
do
    s=$[$i+$s]
    i=$[$i+1]
done
echo $s