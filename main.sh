#!/bin/bash

source ./script/01_check_usr.sh
source ./script/02_check_os.sh
source ./script/03_prereq.sh
source ./script/04_0_kubespray.sh
source ./script/05_InstallLPP.sh
source ./script/07_setMetallbIPRange.sh
source ./script/08_MetaLLB.sh

#CHECK_USR
#CHECK_OS
#PREREQ
#KUBESPARY
installLPP
setMetallbIPRange
setUpMetaLLB