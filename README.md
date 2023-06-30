# kube-task

![demo](https://github.com/hojat-gazestani/kube-task/blob/main/pic/demo.png)

```shell
git clone https://github.com/hojat-gazestani/kube-task.git
cd kube-task/
sudo ./main.sh 
```


## [Local Path Provisioner](https://github.com/rancher/local-path-provisioner)

```shell
echo "Installing Local Path Provisioner"
kubectl apply -f https://github.com/hojat-gazestani/kube-task/blob/main/Local-Path-Provisioner/local-path-storage.yaml

echo "!storageClass: local-path! Successfuly created."
```

## Helm
```shell
echo "Installing Helm 3.12.1"
wget https://get.helm.sh/helm-v3.12.1-linux-amd64.tar.gz
tar xvf helm-v3.12.1-linux-amd64.tar.gz
sudo mv linux-amd64/helm /usr/local/bin
helm version
echo "Helm installation compeleted!"
```


## [treafik](https://doc.traefik.io/traefik/getting-started/install-traefik/)
```shell
echo "Installing traefik..."
helm repo add traefik https://traefik.github.io/charts
helm repo update

helm show values traefik/traefik > traefik-values.yaml
sed -n '568p' traefik-values.yaml
sed -i '568s/expose: false/expose: true/' traefik-values.yaml
sed -n '568p' traefik-values.yaml

helm install traefik traefik/traefik --values traefik-values.yaml -n traefik --create-namespace
echo "Taefik Installing compeleted"
echo "traefik dashboard will be accessable through the $(MetalLB-externalIP):9000"
```

## [mysql]
```shell
helm show values bitnami/mysql > mysql-values.yaml
sed -i "s/storageClass: ""/storageClass: "local-path"/g" mysql-values.yaml

vim mysql-values.yaml
auth:
  rootPassword: "root"
  database: "wp_database"
  username: "user"
  password: "123"

helm install mysql bitnami/mysql --values mysql-values.yaml 
```

## phpmyadmin

```shell
helm show values bitnami/phpmyadmin > phmyadmin-values.yaml
vim phmyadmin-values.yaml
ingress:
  enabled: true
  pathType: phpmyadmin.local
  hostname: phpmyadmin.local
  
db:
  host: "mysql.default.svc.cluster.local"

helm install phpmyadmin ./phpmyadmin/  --values phmyadmin-values.yaml
```


## wordpress

```shell
helm search repo wordpress
helm show values bitnami/wordpress > wordpress-values.yaml
vim wordpress-values.yaml
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

helm install wordpress bitnami/wordpress --values wordpress-values.yaml
```


## argocd

```shell
apiVersion: v1
kind: Service
metadata:
  labels:
    app: nginx
  name: nginx
  namespace: default
spec:
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: nginx
  type: NodePort
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: nginx
  name: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        name: nginx
```

[install argocd](https://github.com/argoproj/argo-cd/releases/tag/v2.7.6)
```shell
kubectl create namespace argocd
# kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.7.6/manifests/install.yaml
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/v2.8.0-rc1/manifests/install.yaml
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

```shell
k -n argocd edit svc argocd-server
   type: NodePort
```

```shell
curl http://192.168.56.6:31551/
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
oZjKzEv3wBySFVt2

admin
oZjKzEv3wBySFVt2

```


