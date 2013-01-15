#!/bin/sh
VirtualBox --startvm $AVM &
AVM_ID=$!
trap "kill $AVM_ID; $ADB disconnect 192.168.56.101; exit 0" 2
$ADB disconnect 192.168.56.101
PING=1
while [ $PING -ne 0 ]
do
  ping -c 1 -w 1 192.168.56.101 > /dev/null
  PING=$?
done
$ADB connect 192.168.56.101
sh -c "cd $AVMPLAYER_DIR;./run.sh 480 720 160"
