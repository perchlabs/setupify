#!/bin/bash
# Environment variables SETUP_ROOT_DIR, OS_DIR and TEMP_DIR are available

# This file is sourced, unlike the other init.d scripts.

initdPrepare() {
  echo -e "${COLOR_SECTION}*** Initialization ***${TEXT_RESET}"

  echo "Obtaining sudo capabilities"
  sudo ls / > /dev/null
  if [[ $? -ne 0 ]]; then
    >&2 echo -e "FAILED to obtain sudo access"
    return 1
  fi

  # Create the tool install directories if they don't exist.
  mkdir -p ~/bin/ "$SOFTWARE_INSTALL_ROOT"

  echo "$PATH" | grep ~/bin > /dev/null 2>&1
  if [[ $? -ne 0 ]]; then
    export PATH="$PATH":~/bin
  fi

  return 0
}
export -f initdPrepare
