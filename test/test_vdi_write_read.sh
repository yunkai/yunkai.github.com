#! /bin/bash

echo "sleep 30s"
pkill sheep
sleep 40
rm -rf /home/yunkai/store/*
i=0
echo "start first 10 sheep ..."
sheep -d /home/yunkai/store/$i -z $i -p $((7000 + $i)) -c zookeeper:127.0.0.1:2181;
sleep 1
for i in {1..9}; do
	sheep -d /home/yunkai/store/$i -z $i -p $((7000 + $i)) -c zookeeper:127.0.0.1:2181;
done;
sleep 2
echo "format cluster ..."
collie cluster format --copies=3 -p 7000

echo "flush 100M info cluster ..."
collie vdi create 'test-vdi' 100M -p 7000
#dd if=/dev/zero count=100M | collie vdi write test-vdi -p 7000

echo "read 1M from 7000 ..."
collie vdi read test-vdi 0 1M -p 7000 > /dev/null

echo "start the 11th sheep ..."
sheep -d /home/yunkai/store/10 -z 10 -p 7010 -c zookeeper:127.0.0.1:2181
sleep 2

echo "read 1M from 7000 ~ 7010 ..."
for i in {0..10}; do
	collie vdi read test-vdi 0 1M -p $((7000 + $i)) > /dev/null;
done;

echo "convert linst img to cluster"
qemu-img convert ../test-img/linux-0.2.img sheepdog:linux
qemu-img convert ../test-img/linux-0.2.img sheepdog:linux2
qemu-img convert ../test-img/linux-0.2.img sheepdog:linux3
sleep 2

qemu-io -n -c "flush" sheepdog:linux
sleep 2
qemu-io -n -c "flush" sheepdog:linux2
sleep 2
qemu-io -n -c "flush" sheepdog:linux3
sleep 2
