#!/bin/bash
#
#
#

#phase I:
#        syn check
syn_check()
{
#0: is data file correct?
## 0.1: is hostname , mac, disk reduntant?
## 0.2: 
##
##
echo "starting synetax check...."
#1: disk
echo "check the disk info...."
while read tmpline
do
if [ "${tmpline:0:1}" = "#" ] ; then
    continue;
fi

disk=`echo $tmpline|awk '{print $4}'`
if [ ! -b $disk ] ; then
    echo "$disk does not exsits!!"
    exit 1;
fi
done<$1

#2: memory
echo "check Memory usage....."
Total_Sys_Mem_kB=`sudo virsh nodeinfo | grep Memory | awk '{print $3}'`
Total_need_Mem_mB=`awk '/^[^#]/{x+=$3} END{print x}' $1`
Total_need_Mem_kB=$((Total_need_Mem_mB*1024))
if [ $Total_Sys_Mem_kB -le $Total_need_Mem_kB ] ; then
    echo "not enough memory !!"
    exit 1;
fi

#3: is that Xend runed?
echo "is xend runed?...."
sudo /etc/init.d/xend status >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "is that Xend runned?"
    exit 1
fi
echo "check finished ,everything's OK"
}

#phase II:
#        There is no problem,
#        start the installation routine
if [ $# -ne 1 ] ; then
    echo "usage: ";
    exit 1
fi
if [ -f $1 ]; then
    DATA=$1
fi

echo $DATA

syn_check $DATA

count=0
while read line
do
#echo $line	

if [ "${line:0:1}" = "#" ] ; then
    continue;
fi

HOSTNAME=`echo $line|awk '{print $1}'`
MAC=`echo $line|awk '{print $2}'`
MEM=`echo $line|awk '{print $3}'`
DISK=`echo $line|awk '{print $4}'`
OS=`echo $line|awk '{print $5}'`
OS_MAJOR=${OS:0:1}
OS_MINOR=${OS:2:1}
ARCH=`echo $line|awk '{print $6}'`

if [ "${ARCH}" == "i386" ]
then
    BITS=32
elif [ "${ARCH}" == "x86_64" -o "${ARCH}" == "X86_64" ]
then
    BITS=64
else
    echo "unrecgnized ARCH infomation, plz check the data file"
    exit 1
fi

echo "vm
HOSTNAME  : $HOSTNAME 
MAC       : $MAC 
MEM       : $MEM MB 
DISK      : $DISK 
OS VERSION: $OS 
ARCH      : $ARCH"

# start the install routine
((count++))
sudo virt-install \
         --paravirt \
         -n $HOSTNAME \
         -r $MEM \
         -l http://broom1.ops.cnz.alimama.com/yum/rhel/versions/$OS_MAJOR/u$OS_MINOR/os/$ARCH/ \
         --network=bridge:xenbr0 \
         --mac=$MAC \
         --file $DISK \
         -x "ks=http://10.2.0.1/broom/getks.php?r=$OS_MAJOR-u$OS_MINOR-$BITS kssendmac ksdevice=bootif" \
         --nographics


if [ $? -ne 0 ]
then
    echo "something error!!"
    exit 1
fi

#now there is 3 guest vm in running, sleep 20 minitues
if [ $((count%2)) -eq 0 ]
then
    sleep 600
fi

done<$DATA

