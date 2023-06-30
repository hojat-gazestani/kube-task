#!/bin/bash

installLPP() {
  echo "Installing Local Path Provisioner..."
  kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.10/config/manifests/metallb-native.yaml

  if [ $? -eq 0 ]; then
    echo "Successfully installed Local Path Provisioner."
  else
    echo "Failed to install Local Path Provisioner."
    exit 1
  fi
}