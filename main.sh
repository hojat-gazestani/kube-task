#!/bin/bash

source ./script/01_check_usr.sh
source ./script/02_check_os.sh
source ./script/03_prereq.sh
source ./script/04_kubespray.sh

CHECK_USR
CHECK_OS
PREREQ
#KUBESPARY