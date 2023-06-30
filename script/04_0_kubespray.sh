#!/bin/bash

source ./script/04_1_setupKubespray.sh
source ./script/04_2_configureKubespray.sh
source ./script/04_3_runKubespray.sh

KUBESPARY() {
  read -p "Please enter your Kubernetes management IP: " NODE

  echo "Setup a Kubernetes cluster on $NODE using Kubespray..."
  read -p "Are you sure you want to setup kubespray Cluster? (y/n): " ANS

  declare -r CLUSTER_FOLDER='my-cluster'
  cd kubespray
  if [[ $ANS =~ ^[Yy]$ ]]; then
    setupKubespray
    #configureKubespray
    runKubespray
  else
    echo "Skipping Kubespray setup."
  fi
  cd ..
}

