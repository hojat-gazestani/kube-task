#!/bin/bash

# Colors for comments
GREEN='\033[0;32m'
NC='\033[0m' # No Color

configureHelm() {
  echo -e "${GREEN}Configuring Helm...${NC}"

  # Check if Bitnami repository is already added
  if helm repo list | grep -q "bitnami"; then
    echo -e "${GREEN}Bitnami repository already exists.${NC}"
    helm repo update
  else
    echo -e "${GREEN}Bitnami repository not found. Adding repository...${NC}"
    helm repo add bitnami https://charts.bitnami.com/bitnami
    helm repo update
  fi
}
