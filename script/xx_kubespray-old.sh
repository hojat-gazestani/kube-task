#!/bin/bash

KUBESPARY() {
read -p "Please enter your Kubernetes management IP: " NODE

# Setup a Kubernete cluster
echo "Setup a Kubernete cluster on on $NODE using Kubespray..."
echo -p "are you sure you want to inter the kubespray directory?" ANS

git clone https://github.com/kubernetes-sigs/kubespray.git
cd kubespray

git checkout release-2.16

# Create Python virtual environment
#sudo apt install python3.8-venv  python3-pip -y
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
pip install --upgrade setuptools
pip install -r requirements.txt


# Copy inventory folder
declare -r CLUSTER_FOLDER='my-cluster'
cp -rfp inventory/local inventory/$CLUSTER_FOLDER

# Generate inventory
declare -a IPS=($NODE)
CONFIG_FILE=inventory/$CLUSTER_FOLDER/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
exit 1
# Configure kubespray settings
sed -i 's/kube_proxy_strict_arp: false/kube_proxy_strict_arp: true/' inventory/$CLUSTER_FOLDER/group_vars/k8s_cluster/k8s-cluster.yml
sed -i 's/container_manager: docker/container_manager: containerd/' inventory/$CLUSTER_FOLDER/group_vars/k8s_cluster/k8s-cluster.yml

sed -i 's/metallb_enabled: false/metallb_enabled: true/'  inventory/$CLUSTER_FOLDER/group_vars/k8s_cluster/addons.yml

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

# Run kubespray playbook
USERNAME=$(whoami)
ansible-playbook -i inventory/$CLUSTER_FOLDER/hosts.ini --connection=local -b -v cluster.yml

# Set up kubeconfig
sudo cp -r /root/.kube $HOME
sudo chown -R $USER $HOME/.kube

}
