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
  if helm install phpmyadmin bitnami/phpmyadmin --values phpmyadmin-values.yaml -n phpmyadmin --create-namespace; then
    echo -e "${GREEN}phpMyAdmin installation completed successfully.${NC}"
  else
    echo -e "${GREEN}Failed to install phpMyAdmin.${NC}"
    exit 1
  fi
}

