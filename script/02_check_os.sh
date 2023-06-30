#!/bin/bash

CHECK_OS() {
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
