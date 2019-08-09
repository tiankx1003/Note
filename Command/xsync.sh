#!/bin/bash

pcount=$#

if ((pcount==0)); then
echo no args;
exit;
fi

p1=$1
fname=`basename $p1`
echo fname=$fname
pdir=`cd -P $(dirname $p1); pwd`
echo pdir=$pdir
user=`whoami`

for((host=101; host<104; host++)); 
do
	echo ------------------- hadoop$host -------------------
	rsync -av $pdir/$fname $user@hadoop$host:$pdir
done