#!/bin/bash

setMetallbIPRange() {
  RANGE=$(echo $NODE | awk -F "." '{print $1"."$2"."$3"."}')
  META_IP="$RANGE.240-$RANGE.250"

  echo "Your management IP address is $NODE."
  echo "Your MetaLLB IP range would be $META_IP."

  read -p "If it is incorrect, please press Y to continue or enter the correct MetaLLB IP range: " ANSWER

  if [[ -z $ANSWER || $ANSWER =~ ^[Yy]$ ]]; then
    echo "Final MetaLLB IP range: $META_IP"
  else
    read -p "Please input the correct MetaLLB IP range: " NEW_META_IP
    META_IP="$NEW_META_IP"
    echo "Final MetaLLB IP range: $META_IP"
  fi
}

#sed "s/RANGE/$META_IP/g" /home/$USER/kube-task/metallb/ipPool.yaml