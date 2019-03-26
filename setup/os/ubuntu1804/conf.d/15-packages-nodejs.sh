#!/usr/bin/env bash
# Environment variables OS_DIR and TEMP_DIR are available

method=$(takeMethod "$NODE_INSTALLER")
[[ -z "$method" ]] && exit 0

# Remove existing repositories.
echo "Removing any existing Node repositories"
sudo rm -f /etc/apt/sources.list.d/nodesource.list > /dev/null

[[ "$method" != repository ]] && exit 0

echo "Installing Node repository"
ref=$(takeRef "$NODE_INSTALLER")

# Create repository list file text
read -r -d '' repositoryText << EOM
# created by setupify.

deb https://deb.nodesource.com/node_${ref}.x bionic main
deb-src https://deb.nodesource.com/node_${ref}.x bionic main
EOM

# Install the Node repository.
echo "$repositoryText" | sudo tee "/etc/apt/sources.list.d/nodesource.list" > /dev/null
if [[ $? -ne 0 ]]; then
  >&2 echo "Unable to install Node.js repository."
  exit 1
fi

exit 0
