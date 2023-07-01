#!/bin/bash

# Define ANSI escape sequences for setting background and font colors
GREEN_BACKGROUND='\033[42m'
BLACK_FONT='\033[30m'
DEFAULT_COLOR='\033[0m'

installMySQL() {
  # Install MySQL
  echo -e "${GREEN_BACKGROUND}${BLACK_FONT}Installing MySQL...${DEFAULT_COLOR}"
  helm install mysql ./mysql || {
    echo -e "${GREEN_BACKGROUND}${BLACK_FONT}Error: Failed to install MySQL .${DEFAULT_COLOR}" >&2
    exit 1
  }

  echo -e "${GREEN_BACKGROUND}${BLACK_FONT}MySQL installation completed.${DEFAULT_COLOR}"
}

