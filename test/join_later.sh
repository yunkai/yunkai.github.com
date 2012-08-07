#! /bin/bash

sheep-clear

set -e

sheep-start 0 1
collie cluster format -c 2
collie cluster recover disable

qemu-img create sheepdog:test 4G

# create 20 objects
for i in `seq 0 19`; do
    collie vdi write test $((i * 4 * 1024 * 1024)) 512 < /dev/zero
done

sheep-start 2 4
sheep-all-epoch
collie cluster recover info

# overwrite the objects
for i in `seq 0 19`; do
    collie vdi write test $((i * 4 * 1024 * 1024)) 512 < /dev/zero
done

collie cluster recover enable
sheep-all-epoch
sheep-node-list 0 4
collie cluster recover disable

sheep-kill 4

#echo read 0 nodes object
#for i in `seq 0 0`; do
#	collie vdi read test -p $((7000 + $i))| md5sum
#done
sheep-all-epoch
sheep-node-list 0 3

echo overwrite the objects
for i in `seq 0 19`; do
    collie vdi write test $((i * 4 * 1024 * 1024)) 512 < /dev/zero
done

collie cluster recover enable
sheep-all-epoch
sheep-proc-list
sheep-node-list 0 3
