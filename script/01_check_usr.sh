#!/bin/bash
GREEN_BACKGROUND='\033[42m'
BLACK_FONT='\033[30m'
DEFAULT_COLOR='\033[0m'

CHECK_USR() {
  if [ "$EUID" -ne 0 ]; then
    echo -e "${GREEN_BACKGROUND}${BLACK_FONT}Please run me as root${DEFAULT_COLOR}"
    exit 1
  fi
}