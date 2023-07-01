#!/bin/bash

# Define ANSI escape sequences for setting background and font colors
GREEN_BACKGROUND='\033[42m'
BLACK_FONT='\033[30m'
DEFAULT_COLOR='\033[0m'

installTraefik() {
  # Create Traefik namespace and install Traefik
  echo -e "${GREEN_BACKGROUND}${BLACK_FONT}Creating Traefik namespace and installing Traefik...${DEFAULT_COLOR}"
  kubectl create namespace traefik || {
    echo -e "${GREEN_BACKGROUND}${BLACK_FONT}Error: Failed to create Traefik namespace .${DEFAULT_COLOR}" >&2
    exit 1
  }
  helm install traefik ./traefik  -n traefik --create-namespace || {
    echo -e "${GREEN_BACKGROUND}${BLACK_FONT}Error: Failed to install Traefik .${DEFAULT_COLOR}" >&2
    exit 1
  }

  # Retrieve Traefik IP for accessing the dashboard
  TR_IP=$(kubectl get svc -n traefik | awk '{print $4}' | tail -n 1)
  echo -e "${GREEN_BACKGROUND}${BLACK_FONT}You have access to the Traefik dashboard at http://$TR_IP:9000${DEFAULT_COLOR}"
}

