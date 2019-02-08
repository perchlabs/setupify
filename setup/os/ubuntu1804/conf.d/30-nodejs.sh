#!/usr/bin/env bash
# Environment variables OS_DIR and TEMP_DIR are available

# You can skip Node steps by exporting this.
[[ ! -z "$SKIP_NODE" ]] && exit 0

echo -e "${COLOR_SECTION}*** Node.js ***${TEXT_RESET}"

cd "$TEMP_DIR"

# Determine the method used for installing Node.js.
method=$(takeMethod "$NODEJS_INSTALL")
case "$method" in
  "")
    echo "No installer specified."
    exit 0
    ;;
  # "tarball")
  #   ref=$(takeRef "$NODEJS_INSTALL")
  #   downloadDir="$TEMP_DIR/nodejs"

  #   mkdir "$downloadDir"
  #   cd "$downloadDir"

  #   # The ref is a url or version.
  #   isUrl "$ref"
  #   isRefUrl=$?
  #   if [[ $isRefUrl -eq 0 ]]; then
  #     url="$ref"
  #   else
  #     version="$ref"
  #     url="https://github.com/nodejs/node/archive/v${version}.tar.gz"
  #   fi

  #   echo "Downloading Node tarball"
  #   tarballFile="node.tarball"
  #   curl --silent -L -o "$tarballFile" "$url"
  #   [[ $? -ne 0 ]] && exit 1

  #   tar -xf "$tarballFile"
  #   [[ $? -ne 0 ]] && exit 1

  #   mysteryDirName=$(ls -d ./*/)
  #   [[ $? -ne 0 ]] && exit 1

  #   cd "$mysteryDirName"
  #   [[ $? -ne 0 ]] && exit 1
  #   ;;
  "repository")
    sudo apt-get install --quiet=2 nodejs
    [[ $? -ne 0 ]] && exit 1
    ;;
  *)
    >&2 echo "Invalid Node installation method."
    exit 1
    ;;
esac

printf "Node.js installed.\n"
