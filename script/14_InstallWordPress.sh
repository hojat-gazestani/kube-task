#!/bin/bash

# Colors for comments
GREEN='\033[0;32m'
NC='\033[0m' # No Color

installWordPress() {
  echo -e "${GREEN}Installing WordPress...${NC}"

  # Generate WordPress values file
  helm show values bitnami/wordpress > wordpress-values.yaml

  # Modify values
  sed -i 's|storageClass: ""|storageClass: "local-path"|' wordpress-values.yaml
  sed -i 's|wordpressUsername: ""|wordpressUsername: user|' wordpress-values.yaml
  sed -i 's|wordpressPassword: ""|wordpressPassword: "123"|' wordpress-values.yaml
  sed -i '600s|enabled: false|enabled: true|' wordpress-values.yaml
  sed -i '1099s|enabled: true|enabled: false|' wordpress-values.yaml
  sed -i '1139s|host: localhost|host: mysql.default.svc.cluster.local|' wordpress-values.yaml
  sed -i 's|user: bn_wordpress|user: user|' wordpress-values.yaml
  sed -i '1148s|password: ""|password: "123"|' wordpress-values.yaml
  sed -i 's|database: bitnami_wordpress|database: wp_database|' wordpress-values.yaml

  # Install WordPress using Helm
  if helm install wordpress bitnami/wordpress --values wordpress-values.yaml; then
    echo -e "${GREEN}WordPress installation completed successfully.${NC}"
    TR_IP=$(kubectl get svc -n traefik | awk '{print $4}' | tail -n 1)
    echo -e "${GREEN_BACKGROUND}${BLACK_FONT}Configure $TR_IP  phpmyadmin.local in you hosts file to have access to PhpMyAdmin.${DEFAULT_COLOR}"
  else
    echo -e "${GREEN}Failed to install WordPress.${NC}"
    exit 1
  fi
}