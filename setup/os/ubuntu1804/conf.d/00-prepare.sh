#!/bin/bash
# Environment variables OS_DIR and TEMP_DIR are available

echo -e "${COLOR_SECTION}*** Initialization ***${TEXT_RESET}"

echo "Attemping sudo capabilities"
sudo ls / > /dev/null
if [[ $? -ne 0 ]]; then
  >&2 echo -e "FAILED to obtain sudo access"
  exit 1
fi

exit 0
