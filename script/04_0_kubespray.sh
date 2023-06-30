#!/bin/bash

source 04_1_setupKubespray.sh
source 04_2_configureKubespray.sh
source 04_3_runKubespray.sh

KUBESPARY() {
  read -p "Please enter your Kubernetes management IP: " NODE

  echo "Setup a Kubernetes cluster on $NODE using Kubespray..."
  read -p "Are you sure you want to enter the kubespray directory? (y/n): " ANS

  if [[ $ANS =~ ^[Yy]$ ]]; then
    setupKubespray
    #configureKubespray
    #runKubespray
  else
    echo "Skipping Kubespray setup."
  fi
}

