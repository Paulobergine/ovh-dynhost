#!/bin/sh

for DDN in $DDNS
do
  echo "Checking IP" >> /usr/src/app/dynhost.log

  IP=$(dig -4 TXT +short o-o.myaddr.l.google.com @ns1.google.com | tr -d \")
  CURRENT_IP=$(dig +short $DDN)

  if [ "$IP" ]; then
    if [ "$CURRENT_IP" != "$IP" ]; then
        echo "Updating $DDN from $CURRENT_IP to $IP" >> dynhost.log
        curl --user "${LOGIN}:${PASSWORD}" "http://www.ovh.com/nic/update?system=dyndns&hostname=${DDN}&myip=${IP}" >> dynhost.log 2>&1
    else
        echo "No update required" >> dynhost.log
    fi
  else
    echo "IP not found" >> dynhost.log
  fi
done
