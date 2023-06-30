#!/bin/bash
setUpMetaLLB() {
kubectl apply -f /home/$USER/kube-task//metallb/metallb-native.yaml
kubectl apply -f /home/$USER/kube-task//metallb/ipPool.yaml
kubectl apply -f /home/$USER/kube-task//metallb/l2adver.yaml
}