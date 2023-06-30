#!/bin/bash


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
