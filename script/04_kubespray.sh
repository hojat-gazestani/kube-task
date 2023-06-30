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

configureKubespray() {
  echo "Configuring Kubespray..."

  # Generate inventory
  declare -a IPS=($NODE)
  CONFIG_FILE=inventory/$CLUSTER_FOLDER/hosts.yaml python3 contrib/inventory_builder/inventory.py "${IPS[@]}"

  # Configure kubespray settings
  sed -i 's/kube_proxy_strict_arp: false/kube_proxy_strict_arp: true/' inventory/$CLUSTER_FOLDER/group_vars/k8s_cluster/k8s-cluster.yml
  sed -i 's/container_manager: docker/container_manager: containerd/' inventory/$CLUSTER_FOLDER/group_vars/k8s_cluster/k8s-cluster.yml

  sed -i 's/metallb_enabled: false/metallb_enabled: true/' inventory/$CLUSTER_FOLDER/group_vars/k8s_cluster/addons.yml

  cat >> inventory/$CLUSTER_FOLDER/group_vars/k8s_cluster/addons.yml << EOF
metallb_ip_range:
  - "10.5.0.50-10.5.0.50"
metallb_controller_tolerations:
  - key: "node-role.kubernetes.io/master"
    operator: "Equal"
    value: ""
    effect: "NoSchedule"
  - key: "node-role.kubernetes.io/control-plane"
    operator: "Equal"
    value: ""
    effect: "NoSchedule"
EOF

  sed -i 's|etcd_deployment_type: docker|etcd_deployment_type: host|' inventory/$CLUSTER_FOLDER/group_vars/etcd.yml

  cat >> inventory/$CLUSTER_FOLDER/group_vars/all/containerd.yml << EOF
containerd_registries:
  "docker.io":
    - "https://mirror.gcr.io"
    - "https://registry-1.docker.io"
EOF
}

runKubespray() {
  echo "Running Kubespray..."

  # Run Kubespray playbook
  USERNAME=$(whoami)
  ansible-playbook -i inventory/$CLUSTER_FOLDER/hosts.ini --connection=local -b -v cluster.yml

  # Set up kubeconfig
  sudo cp -r /root/.kube $HOME
  sudo chown -R $USER $HOME/.kube
}

KUBESPARY() {
  read -p "Please enter your Kubernetes management IP: " NODE

  echo "Setup a Kubernetes cluster on $NODE using Kubespray..."
  read -p "Are you sure you want to enter the kubespray directory? (y/n): " ANS

  if [[ $ANS =~ ^[Yy]$ ]]; then
    setupKubespray
    configureKubespray
    runKubespray
  else
    echo "Skipping Kubespray setup."
  fi
}

KUBESPARY