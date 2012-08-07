pkill -9 sheep
pkill -9 collie
rm store/* -rf
for i in `seq 0 0`; do sheep/sheep -d /home/tailai.ly/sheepdog/store/$i -z $i -p $((7000+$i));done
sleep 1
for i in `seq 1 7`; do sheep/sheep -d /home/tailai.ly/sheepdog/store/$i -z $i -p $((7000+$i));done
sleep 3
collie/collie cluster format  -c 3
sleep 1

for i in `seq 0 4`;do
	collie/collie vdi create test$i 100M -p 7001
done

for i in `seq 0 4`;do
dd if=/dev/urandom | collie/collie vdi write test$i -p 7001 &
done

sleep 3
for i in 1 2 3 4 5; do pkill -f "sheep/sheep -d /home/tailai.ly/sheepdog/store/$i -z $i -p 700$i";sleep 3;done;
ps -ef | grep sheep
for i in `seq 1 5`; do sheep/sheep -d /home/tailai.ly/sheepdog/store/$i -z $i -p $((7000+$i));done

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
		./collie/collie vdi read test$j -p 700$i | md5sum 
	done
done
