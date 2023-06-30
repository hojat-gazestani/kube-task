#!/bin/bash

source ./script/01_check_usr.sh
source ./script/02_check_os.sh
source ./script/03_prereq.sh
source ./script/04_0_kubespray.sh
source ./script/05_InstallLPP.sh
source ./script/07_setMetallbIPRange.sh
source ./script/08_MetaLLB.sh
source ./script/09-InstallHelm.sh

## Run me as root
#CHECK_USR

## Check if OS release is Ubuntu 20.04
#CHECK_OS

## configuring kubernetes cluster pre requirements
#PREREQ

## Bootstrapping kubernetes cluster with kubespray
#KUBESPARY

## Installing Local Path Provisioner
installLPP

## Setting MetaLLB IP range
#setMetallbIPRange

##  Installation of Local Path Provisioner
#setUpMetaLLB


# Installing  Helm
installHelm
# Check Helm version
helmVersion