#!/bin/bash

pkill -9 sheep

#cd /var/lib/sheepdog
#rm -rf disc*/*
#for DIR in $(ls -d disc*); do
#        ln -s /etc/sheepdog/$DIR.setup $DIR/setup;
#done

sheep-clear
#/etc/init.d/sheepdog start
sheep-start 0 3

collie cluster format -c 3
for ((i=0;i<5;i++)); do
        qemu-img create -f raw sheepdog:test$i 10M
        qemu-io -c "write -P 0x01 0 10M" sheepdog:test$i
done
echo "collie vdi object test2 -i 2 # ok, no problem"
collie vdi object test2 -i 2 # ok, no problem
echo "collie cluster cleanup       # ok, no problem"
collie cluster cleanup       # ok, no problem

# but now ...
echo "collie cluster shutdown"
collie cluster shutdown
sleep 6
#/etc/init.d/sheepdog start
sheep-start 0 3

echo "collie vdi object test2 -i 2 # gateway-only crashes !!!!"
collie vdi object test2 -i 2 # gateway-only crashes !!!!
sheep-proc-list

exit
/etc/init.d/sheepdog start

echo "collie cluster cleanup       # gateway-only crashes !!!!"
collie cluster cleanup       # gateway-only crashes !!!!
