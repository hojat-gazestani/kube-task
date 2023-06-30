#!/bin/bash
GREEN_BACKGROUND='\033[42m'
BLACK_FONT='\033[30m'
DEFAULT_COLOR='\033[0m'


installHelm() {
  echo "Installing Helm..."

  # Download Helm package
  wget https://get.helm.sh/helm-v3.12.1-linux-amd64.tar.gz || {
    echo -e "${GREEN_BACKGROUND}${BLACK_FONT}Error: Failed to download Helm package.${DEFAULT_COLOR}" >&2
    exit 1
  }

  # Extract Helm package
  tar xvf helm-v3.12.1-linux-amd64.tar.gz || {
    echo -e "${GREEN_BACKGROUND}${BLACK_FONT}Error: Failed to extract Helm package.${DEFAULT_COLOR}" >&2
    exit 1
  }

  # Move Helm binary to /usr/local/bin
  sudo mv linux-amd64/helm /usr/local/bin || {
    echo -e "${GREEN_BACKGROUND}${BLACK_FONT}Error: Failed to move Helm binary to /usr/local/bin.${DEFAULT_COLOR}" >&2
    exit 1
  }

  echo -e "${GREEN_BACKGROUND}${BLACK_FONT}Helm installed successfully!${DEFAULT_COLOR}"
}

helmVersion() {
  echo -e "${GREEN_BACKGROUND}${BLACK_FONT}Checking Helm version...${DEFAULT_COLOR}"
  helm version
}

