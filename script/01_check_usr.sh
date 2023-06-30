#!/bin/bash

CHECK_USR() {
  if [ "$EUID" -ne 0 ]; then
    echo "Please run me as root"
    exit 1
  fi
}