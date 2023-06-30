#!/bin/bash
GREEN_BACKGROUND='\033[42m'
BLACK_FONT='\033[30m'
DEFAULT_COLOR='\033[0m'

# https://github.com/rancher/local-path-provisioner
installLPP() {
  echo -e "${GREEN_BACKGROUND}${BLACK_FONT}Installing Local Path Provisioner...${DEFAULT_COLOR}"
  kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.24/deploy/local-path-storage.yaml

  if [ $? -eq 0 ]; then
    echo  -e "${GREEN_BACKGROUND}${BLACK_FONT}Successfully installed Local Path Provisioner.${DEFAULT_COLOR}"
  else
    echo  -e "${GREEN_BACKGROUND}${BLACK_FONT}Failed to install Local Path Provisioner.${DEFAULT_COLOR}"
    exit 1
  fi
}