#!/bin/bash
# Environment variables SETUP_DIR, CUSTOM_DIR, PLATFORM_DIR and TEMP_DIR are available

# This file is sourced and all variables will be automatically exported.

PHP_VERSION=${PHP_VERSION:-7.4}
PHP_ETC=${PHP_ETC:-/etc/php/$PHP_VERSION}
DEBIAN_FRONTEND=${DEBIAN_FRONTEND:-noninteractive}

MARIADB_HOST=${DATABASE_HOST:-localhost}

# This function is run just prior to starting the init.d scripts.
initdPrepare() {
  echo -e "${COLOR_SECTION}*** Initialization ***${TEXT_RESET}"

  # Create the tool install directories if they don't exist.
  mkdir -p ~/bin/ "$SOFTWARE_INSTALL_ROOT"

  echo "$PATH" | grep ~/bin > /dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    export PATH="$PATH":~/bin
  fi

  return 0
}
export -f initdPrepare
