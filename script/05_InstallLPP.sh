#!/bin/bash

installLPP() {
  echo "Installing Local Path Provisioner..."
  kubectl apply -f https://github.com/hojat-gazestani/kube-task/blob/main/Local-Path-Provisioner/local-path-storage.yaml

  if [ $? -eq 0 ]; then
    echo "Successfully installed Local Path Provisioner."
  else
    echo "Failed to install Local Path Provisioner."
    exit 1
  fi
}