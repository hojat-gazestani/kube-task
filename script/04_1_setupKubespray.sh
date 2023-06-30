#!/bin/bash

setupKubespray() {
  echo "Setting up Kubespray..."

  git clone https://github.com/kubernetes-sigs/kubespray.git || {
    echo "Error: Failed to clone Kubespray repository." >&2
    exit 1
  }
  cd kubespray || {
    echo "Error: Failed to change directory to kubespray." >&2
    exit 1
  }
  git checkout release-2.16 || {
    echo "Error: Failed to switch to release-2.16 branch." >&2
    exit 1
  }

  sudo apt install python3.8-venv python3-pip -y
  # Create Python virtual environment
  python3 -m venv venv
  source venv/bin/activate

  # Install Python dependencies
  pip install --upgrade setuptools
  pip install -r requirements.txt

  # Copy inventory folder
  declare -r CLUSTER_FOLDER='my-cluster'
  cp -rfp inventory/local inventory/$CLUSTER_FOLDER
}
