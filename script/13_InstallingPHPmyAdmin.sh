#!/bin/bash

# Colors for comments
GREEN='\033[0;32m'
NC='\033[0m' # No Color

installPhpMyAdmin() {
  echo -e "${GREEN}Installing phpMyAdmin...${NC}"

  # Generate phpMyAdmin values file
  helm show values bitnami/phpmyadmin > phpmyadmin-values.yaml

  # Modify values
  sed -i '384s|enabled: false|enabled: true|' phpmyadmin-values.yaml
  sed -i '515s|host: ""|host: "mysql.default.svc.cluster.local"|' phpmyadmin-values.yaml

  # Install phpMyAdmin using Helm
  if helm install phpmyadmin bitnami/phpmyadmin --values phpmyadmin-values.yaml; then
    echo -e "${GREEN}phpMyAdmin installation completed successfully.${NC}"
    TR_IP=$(kubectl get svc -n traefik | awk '{print $4}' | tail -n 1)
    echo -e "${GREEN_BACKGROUND}${BLACK_FONT}Configure $TR_IP  phpmyadmin.local in you hosts file to have access to PhpMyAdmin.${DEFAULT_COLOR}"
  else
    echo -e "${GREEN}Failed to install phpMyAdmin.${NC}"
    exit 1
  fi


}

