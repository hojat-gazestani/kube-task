#!/bin/bash

# Define ANSI escape sequences for setting background and font colors
GREEN_BACKGROUND='\033[42m'
BLACK_FONT='\033[30m'
DEFAULT_COLOR='\033[0m'

MyPhpMyAdmin() {
  echo -e "${GREEN_BACKGROUND}${BLACK_FONT}Installing My phpMyAdmin...${DEFAULT_COLOR}"

  # Install phpMyAdmin using Helm
  if helm install Myphpmyadmin ./My-phpmyadmin ; then
    echo -e "${GREEN_BACKGROUND}${BLACK_FONT}My phpMyAdmin installation completed successfully.${DEFAULT_COLOR}"
    TR_IP=$(kubectl get svc -n traefik | awk '{print $4}' | tail -n 1)
    echo -e "${GREEN_BACKGROUND}${BLACK_FONT}Configure $TR_IP  My phpmyadmin.local in you hosts file to have access to PhpMyAdmin.${DEFAULT_COLOR}"
  else
    echo -e "${GREEN_BACKGROUND}${BLACK_FONT}Failed to install My phpMyAdmin.${DEFAULT_COLOR}"
    exit 1
  fi
}