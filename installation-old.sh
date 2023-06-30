#!/bin/bash

NODE=192.168.56.6

# Check if OS release is Ubuntu 20.04
if [[ $(lsb_release -rs) != "20.04" ]]; then
    read -p "Hojat tested me on Ubuntu 20.04, but this is os-release. Would you like to continue? (y/n): " answer
    if [[ ! $answer =~ ^[Yy]$|^yes$ ]]; then
        exit 1
    fi
fi



# Setup a Kubernete cluster
echo "Setup a Kubernete cluster on on $NODE using Kubespray..."
cd kubespray
git checkout release-2.16

# Create Python virtual environment
sudo apt install python3.8-venv python3-pip -y
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
sudo apt install python3-pip
pip3 install -r requirements.txt
pip3 install --upgrade setuptools

# Copy inventory folder
declare -r CLUSTER_FOLDER='my-cluster'
cp -rfp inventory/local inventory/$CLUSTER_FOLDER

# Generate inventory
declare -a IPS=(192.168.56.6)
CONFIG_FILE=inventory/$CLUSTER_FOLDER/hosts.yaml python3 contrib/inventory_builder/inventory.py "$NODE"

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

# Install Local Path Provisioner
echo "Installing Local Path Provisioner"
kubectl apply -f https://github.com/hojat-gazestani/kube-task/blob/main/Local-Path-Provisioner/local-path-storage.yaml

echo "!storageClass: local-path! Successfully created."

# Install Helm
echo "Installing Helm 3.12.1"
wget https://get.helm.sh/helm-v3.12.1-linux-amd64.tar.gz
tar xvf helm-v3.12.1-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin

OUTPUT=$(helm version)

if [[ ! $OUTPUT =~ ^version ]]; then
    echo "Helm installation was not successful!"
    exit
else
    echo "Helm installation completed!"
fi

# Install Traefik
echo "Installing Traefik..."
helm repo add traefik https://traefik.github.io/charts
helm repo update

helm show values traefik/traefik > traefik-values.yaml
sed -i '568s/expose: false/expose: true/' traefik-values.yaml

helm install traefik traefik/traefik --values traefik-values.yaml -n traefik --create-namespace
echo "Traefik installation completed"
echo "Traefik dashboard will be accessible through the `kubectl get svc -n traefik | awk '{print $4}' | tail -n 1`:9000"

# Install MySQL
echo "Installing MySQL..."
helm show values bitnami/mysql > mysql-values.yaml
sed -i "s/storageClass: \"\"/storageClass: \"local-path\"/g" mysql-values.yaml

vim mysql-values.yaml << EOF
auth:
  rootPassword: "root"
  database: "wp_database"
  username: "user"
  password: "123"
EOF

helm install mysql bitnami/mysql --values mysql-values.yaml
echo "MySQL installation completed"

# Install phpMyAdmin
echo "Installing phpMyAdmin..."
helm show values bitnami/phpmyadmin > phpmyadmin-values.yaml
vim phpmyadmin-values.yaml << EOF
ingress:
  enabled: true
  pathType: phpmyadmin.local
  hostname: phpmyadmin.local
  
db:
  host: "mysql.default.svc.cluster.local"
EOF

helm install phpmyadmin bitnami/phpmyadmin --values phpmyadmin-values.yaml
echo "phpMyAdmin installation completed"

# Install WordPress
echo "Installing WordPress..."
helm search repo wordpress
helm show values bitnami/wordpress > wordpress-values.yaml
vim wordpress-values.yaml << EOF
global:
  storageClass: "local-path"

wordpressUsername: user
wordpressPassword: "123"

wordpressFirstName: Hojat
wordpressLastName: Gazestani

wordpressBlogName: Kubernetes Blog

ingress:
  enabled: true
  pathType: wordpress.local
  hostname: wordpress.local

mariadb:
  enabled: false

externalDatabase: 
  host: mysql.default.svc.cluster.local
  user: user
  password: "123"
  database: wp_database
EOF

helm install wordpress bitnami/wordpress --values wordpress-values.yaml
echo "WordPress installation completed"
