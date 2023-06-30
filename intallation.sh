#!/bin/bash

#figlet Hojat task demon
#neofetch

CHECK_USR() {
  if [ "$EUID" -ne 0 ]; then
    echo "Please run me as root"
    exit 1
  fi
}

TEST_OS() {
    # Check if OS release is Ubuntu 20.04
    DETECTE_OS=`lsb_release -d | awk '{print $2" "$3}'`
    if [[ $(lsb_release -rs) != "20.04" ]]; then
        read -p "Hojat tested me on Ubuntu 20.04, but this is $DETECTE_OS. Would you like to continue? (y/n): " answer
        if [[ ! $answer =~ ^[Yy]$|^yes$ ]]; then
            exit 1
        fi
	echo `lsb_release -d | awk '{print $2" "$3}'`
    fi
}


PREREQ() {
sudo sed -ri '/\sswap\s/s/^#?/#/' /etc/fstab
sudo swapoff -a

sudo systemctl stop apparmor
sudo systemctl disable apparmor

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system
}

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

CHECK_USR
TEST_OS
PREREQ
KUBESPARY
