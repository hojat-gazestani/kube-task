#!/bin/bash

runKubespray() {
  echo "Running Kubespray..."

  # Run Kubespray playbook
  USERNAME=$(whoami)
  ansible-playbook -i inventory/$CLUSTER_FOLDER/hosts.ini --connection=local -b -v cluster.yml || {
    echo "Error: Failed to Run Kubespray playbook." >&2
    exit 1
  }

  # Set up kubeconfig
  sudo cp -r /root/.kube $HOME || {
    echo "Error: Failed to Set up kubeconfig." >&2
    exit 1
  }
  sudo chown -R $USER $HOME/.kube || {
    echo "Error: Failed to set kubeconfig owner." >&2
    exit 1
  }
  kubectl get nodes

  sudo kubectl version
}
