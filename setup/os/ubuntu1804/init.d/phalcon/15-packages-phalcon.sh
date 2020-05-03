#!/usr/bin/env bash
# Environment variables SETUP_ROOT_DIR, OS_DIR and TEMP_DIR are available

method=$(takeMethod "$PHALCON_INSTALLER")
[[ -z "$method" ]] && exit 0

# Remove any existing Phalcon repository.  This could prevent
# two repository sources existing if the channel was changed.
ls /etc/apt/sources.list.d/phalcon*.list > /dev/null 2>&1
if [[ $? -ne 0 ]]; then
  echo "Removing the existing Phalcon repositories."
  sudo rm -f /etc/apt/sources.list.d/phalcon*.list > /dev/null
fi

# If the Phalcon method is 'repository' then install it.
if [[ "$method" == repository ]]; then
  ref=$(takeRef "$PHALCON_INSTALLER")

  # Install the Phalcon repository.
  echo "Installing Phalcon repository for '$ref'"
  curl -s "https://packagecloud.io/install/repositories/phalcon/${ref}/script.deb.sh" | sudo bash
  if [[ $? -ne 0 ]]; then
    >&2 echo "Unable to install Phalcon repository."
    exit 1
  fi
fi

exit 0
