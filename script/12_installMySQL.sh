#!/bin/bash

# Define ANSI escape sequences for setting background and font colors
GREEN_BACKGROUND='\033[42m'
BLACK_FONT='\033[30m'
DEFAULT_COLOR='\033[0m'

installMySQL() {
  # Retrieve MySQL values and configure
  echo -e "${GREEN_BACKGROUND}${BLACK_FONT}Retrieving MySQL values and configuring...${DEFAULT_COLOR}"
  helm show values bitnami/mysql > mysql-values.yaml
  sed -i 's|rootPassword: ""|rootPassword: "root"|' mysql-values.yaml
  sed -i 's|database: "my_database"|database: "wp_database"|' mysql-values.yaml
  sed -i 's|username: ""|username: "user"|' mysql-values.yaml
  sed -i 's|password: ""|password: "123"|' mysql-values.yaml
  sed -i 's/storageClass: ""/storageClass: "local-path"/g' mysql-values.yaml

  # Install MySQL
  echo -e "${GREEN_BACKGROUND}${BLACK_FONT}Installing MySQL...${DEFAULT_COLOR}"
  helm install mysql bitnami/mysql --values mysql-values.yaml

  TR_IP=$(kubectl get svc -n traefik | awk '{print $4}' | tail -n 1)
  echo -e "${GREEN_BACKGROUND}${BLACK_FONT}MySQL installation completed.${DEFAULT_COLOR}"
  echo -e "${GREEN_BACKGROUND}${BLACK_FONT}Configure $TR_IP  phpmyadmin.local in you hosts file to have access to PhpMyAdmin.${DEFAULT_COLOR}"
}

