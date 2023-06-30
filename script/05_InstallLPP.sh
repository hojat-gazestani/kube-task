#!/bin/bash

installLPP() {
  echo "Installing Local Path Provisioner..."
  kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.24/deploy/local-path-storage.yaml

  if [ $? -eq 0 ]; then
    echo "Successfully installed Local Path Provisioner."
  else
    echo "Failed to install Local Path Provisioner."
    exit 1
  fi
}