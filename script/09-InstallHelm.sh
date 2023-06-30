#!/bin/bash

installHelm() {
  echo "Installing Helm..."

  # Download Helm package
  wget https://get.helm.sh/helm-v3.12.1-linux-amd64.tar.gz || {
    echo "Error: Failed to download Helm package." >&2
    exit 1
  }

  # Extract Helm package
  tar xvf helm-v3.12.1-linux-amd64.tar.gz || {
    echo "Error: Failed to extract Helm package." >&2
    exit 1
  }

  # Move Helm binary to /usr/local/bin
  sudo mv linux-amd64/helm /usr/local/bin || {
    echo "Error: Failed to move Helm binary to /usr/local/bin." >&2
    exit 1
  }

  echo "Helm installed successfully!"
}

helmVersion() {
  echo "Checking Helm version..."
  helm version
}

