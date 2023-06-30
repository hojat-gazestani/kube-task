#!/bin/bash

# Define ANSI escape sequences for setting background and font colors
GREEN_BACKGROUND='\033[42m'
BLACK_FONT='\033[30m'
DEFAULT_COLOR='\033[0m'

installTraefik() {
  # Add Traefik Helm repository
  echo -e "${GREEN_BACKGROUND}${BLACK_FONT}Adding Traefik Helm repository...${DEFAULT_COLOR}"
  helm repo add traefik https://traefik.github.io/charts || {
    echo -e "${GREEN_BACKGROUND}${BLACK_FONT}Error: Failed to add Traefik Helm repository.${DEFAULT_COLOR}" >&2
    exit 1
  }

  helm repo update || {
    echo -e "${GREEN_BACKGROUND}${BLACK_FONT}Error: Failed to add update Helm repository.${DEFAULT_COLOR}" >&2
    exit 1
  }

  # Retrieve Traefik values and enable expose
  echo -e "${GREEN_BACKGROUND}${BLACK_FONT}Retrieving Traefik values and enabling expose...${DEFAULT_COLOR}"
  helm show values traefik/traefik > traefik-values.yaml || {
    echo -e "${GREEN_BACKGROUND}${BLACK_FONT}Error: Failed to retrieve Traefik values and enable expose.${DEFAULT_COLOR}" >&2
    exit 1
  }
  sed -i '568s|expose: false|expose: true|' traefik-values.yaml

  # Create Traefik namespace and install Traefik
  echo -e "${GREEN_BACKGROUND}${BLACK_FONT}Creating Traefik namespace and installing Traefik...${DEFAULT_COLOR}"
  kubectl create namespace traefik || {
    echo -e "${GREEN_BACKGROUND}${BLACK_FONT}Error: Failed to create Traefik namespace .${DEFAULT_COLOR}" >&2
    exit 1
  }
  helm install traefik traefik/traefik --values traefik-values.yaml -n traefik --create-namespace || {
    echo -e "${GREEN_BACKGROUND}${BLACK_FONT}Error: Failed to install Traefik .${DEFAULT_COLOR}" >&2
    exit 1
  }

  # Retrieve Traefik IP for accessing the dashboard
  TR_IP=$(kubectl get svc -n traefik | awk '{print $4}' | tail -n 1)
  echo -e "${GREEN_BACKGROUND}${BLACK_FONT}You have access to the Traefik dashboard at http://$TR_IP:9000${DEFAULT_COLOR}"
}

