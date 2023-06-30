#!/bin/bash

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
