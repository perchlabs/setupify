#!/usr/bin/env bash
# Environment variables OS_DIR and TEMP_DIR are available

[[ ! -z "$SKIP_PACKAGES" ]] && exit 0

# Remove existing installed Phalcon repositories.
echo "Removing any existing Phalcon repositories"
sudo rm -f /etc/apt/sources.list.d/phalcon*.list > /dev/null

# If the Phalcon method is not 'repository' then exit
method=$(takeMethod "$PHALCON_INSTALL")
[[ "$method" != repository ]] && exit 0

echo "Installing Phalcon repository"
ref=$(takeRef "$PHALCON_INSTALL")

# Create repository list file text
read -r -d '' repositoryText << EOM
# created by setupify.
# see the repository at https://packagecloud.io/phalcon/${ref}

deb https://packagecloud.io/phalcon/${ref}/ubuntu/ bionic main
deb-src https://packagecloud.io/phalcon/${ref}/ubuntu/ bionic main
EOM

# Install the Phalcon repository.
echo "$repositoryText" | sudo tee "/etc/apt/sources.list.d/phalcon_${ref}.list" > /dev/null
if [[ $? -ne 0 ]]; then
  >&2 echo "Unable to install Phalcon repository."
  exit 1
fi

exit 0
