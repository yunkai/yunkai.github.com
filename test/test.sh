#! /bin/bash

drv="-c zookeeper:127.0.0.1:2181"

pkill sheep
rm -rf /store/*
sleep 40
echo create sheep [0..7]
for i in `seq 0 7`; do sheep -d /store/$i -z $i -p $((7000+$i)) $drv;sleep 1;done
collie cluster format  -c 3
echo create new vdis
(
for i in `seq 0 40`;do
collie vdi create test$i 4M
done
) &

exit 1

sleep 1
echo kill nodes
for i in 1 2 3 4 5; do pkill -f "sheep -d /store/$i -z $i -p 700$i $drv";sleep 1;done;
exit 1
echo sleep 40s
sleep 40
ps -ef | grep sheep

echo "restart sheep [1..5]"
for i in `seq 1 5`; do sheep -d /store/$i -z $i -p $((7000+$i)) $drv;done

echo wait for object recovery to finish
for ((;;)); do
        if [ "$(pgrep collie)" ]; then
                sleep 1
        else
                break
        fi
done
exit 1
