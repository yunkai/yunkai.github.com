#! /bin/bash

drv="-c zookeeper:127.0.0.1:2181"

echo "clear /store/* ..."
pkill sheep
/home/yunkai/collie/rmipcs.sh
rm -rf /store/*

echo "start first [0..3] sheep ..."
for i in {0..3}; do sheep -d /store/$i -z $i -p $((7000 + $i)) $drv; sleep 1; done;

echo "format cluster ..."
collie cluster format --copies=3 -p 7000
find /store/ -name epoch | xargs ls

#echo "flush 100M info cluster ..."
#collie vdi create 'test-vdi' 100M -p 7000
#dd if=/dev/zero count=100M | collie vdi write test-vdi -p 7000
#
#echo "read 1M from 7000 ..."
#collie vdi read test-vdi 0 1M -p 7000 > /dev/null

echo "kill [0..3] sheep"
for i in {0..3}; do
	ps -ef | grep sheep | grep -v grep | grep  $((7000 + $i)) | \
		sed -n '/^[a-z]\+ \+[0-9]\+ \+1 /p' | \
		awk '{print $2}' | xargs -I {} kill -9 {};
	sleep 12; 
done
sleep 2
find /store/ -name epoch | xargs ls

echo "restart [0..3] sheep"
for i in {0..3}; do sheep -d /store/$i -z $i -p $((7000 + $i)) $drv; sleep 10; done;
find /store/ -name epoch | xargs ls
