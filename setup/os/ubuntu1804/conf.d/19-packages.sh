#!/usr/bin/env bash
# Environment variables OS_DIR and TEMP_DIR are available

[[ ! -z "$SKIP_PACKAGES" ]] && exit 0

# Update packages again for PPA repositories.
echo "Updating package cache again (for PPAs)"
sudo apt-get update --quiet=2

exit 0
