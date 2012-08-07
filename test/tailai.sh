#! /bin/bash

pkill -9 sheep
pkill -9 collie
rm -rf /home/yunkai/store/*
echo "start 0 sheep ..."
for i in `seq 0 0`; do sheep -d /home/yunkai/store/$i -z $i -p $((7000+$i));done
sleep 1
echo "start 1..7 sheep ..."
for i in `seq 1 7`; do sheep -d /home/yunkai/store/$i -z $i -p $((7000+$i));done
sleep 3
collie cluster format  -c 3
sleep 1

for i in `seq 0 4`; do
	collie vdi create test$i 100M -p 7001;
done

for i in `seq 0 4`; do
dd if=/dev/urandom | collie vdi write test$i -p 7001 &
done

sleep 3
echo "kill 1..5 sheeps ..."
for i in 1 2 3 4 5; do pkill -f "sheep -d /home/yunkai/store/$i -z $i -p 700$i";sleep 3;done;
ps -ef | grep sheep
echo "restart 1..5 sheeps ..."
for i in `seq 1 5`; do sheep -d /home/yunkai/store/$i -z $i -p $((7000+$i));done

echo wait for object recovery to finish
for ((;;)); do
        if [ "$(pgrep collie)" ]; then
                sleep 1
        else
                break
        fi
done

for i in `seq 0 7`; do
	for j in `seq 0 4`; do
		collie vdi read test$j -p 700$i | md5sum 
	done
done
