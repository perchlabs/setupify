#!/usr/bin/env bash
# Environment variables OS_DIR and TEMP_DIR are available

[[ ! -z "$SKIP_PACKAGES" ]] && exit 0

echo -e "${COLOR_SECTION}*** System Packages ***${TEXT_RESET}"

echo "Updating package cache"
sudo apt-get update --quiet=2 > /dev/null
if [[ $? -ne 0 ]]; then
  >&2 echo "Unable to update the package cache."
  exit 1
fi

echo "Installing software-properties-common"
sudo apt-get install --quiet=2 --assume-yes software-properties-common
[[ $? -ne 0 ]] && exit 1

# If the Phalcon method is 'repository' then add the repository.
phalconMethod=$(takeMethod "$PHALCON_INSTALL")
if [[ "$phalconMethod" = repository ]]; then
  echo "Installing Phalcon repository"
  phalconRef=$(takeRef "$PHALCON_INSTALL")
  cmd="curl -s 'https://packagecloud.io/install/repositories/phalcon/${phalconRef}/script.deb.sh' | sudo bash"
  eval "$cmd"
  if [[ $? -ne 0 ]]; then
    >&2 echo "Unable to add the Phalcon repository."
    exit 1
  fi
fi

# Update again after PPA changes. Uncomment these if you need to refresh the cache.
# sudo apt-get update
# sudo apt-get upgrade -y

echo "Installing system packages"
packages=$(readlist package)
sudo apt-get install --quiet=2 --assume-yes $packages
if [[ $? -ne 0 ]]; then
  >&2 echo "Unable to install the system packages."
  exit 1
fi

exit 0
