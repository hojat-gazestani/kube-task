#!/bin/bash

#figlet Hojat task demon
#neofetch
CHECK_USR() {
  if [ "$EUID" -ne 0 ]; then
    echo "Please run this script as root"
    exit 1
  fi
}

function TEST_OS {
    # Check if OS release is Ubuntu 20.04
    DETECTE_OS=`lsb_release -d | awk '{print $2" "$3}'`
    if [[ $(lsb_release -rs) != "20.04" ]]; then
        read -p "Hojat tested me on Ubuntu 20.04, but this is $DETECTE_OS. Would you like to continue? (y/n): " answer
        if [[ ! $answer =~ ^[Yy]$|^yes$ ]]; then
            exit 1
        fi
	echo `lsb_release -d | awk '{print $2" "$3}'`
    fi
}

function PREREQ {
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system
}


CHECK_USR
TEST_OS
PREREQ

