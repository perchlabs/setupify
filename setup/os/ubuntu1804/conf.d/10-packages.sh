#!/usr/bin/env bash
# Environment variables OS_DIR and TEMP_DIR are available

[[ ! -z "$SKIP_PACKAGES" ]] && exit 0

echo -e "${COLOR_SECTION}*** System Packages ***${TEXT_RESET}"

# Some hosted VMs start without a package cache.
echo "Updating package cache"
sudo apt-get update --quiet=2 > /dev/null
if [[ $? -ne 0 ]]; then
  >&2 echo "Unable to update the package cache."
  exit 1
fi

# Upgrade the installed packages.
echo "Upgrading packages"
sudo apt-get upgrade --quiet=2 -y
if [[ $? -ne 0 ]]; then
  >&2 echo "Unable to upgrade the packages."
  exit 1
fi

# Some hosted VMs start without this essential package installed.
echo "Installing software-properties-common"
sudo apt-get install --quiet=2 --assume-yes software-properties-common
[[ $? -ne 0 ]] && exit 1

exit 0
