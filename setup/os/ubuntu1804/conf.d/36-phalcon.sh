#!/usr/bin/env bash
# Environment variables OS_DIR and TEMP_DIR are available

# You can skip Phalcon steps by exporting this.
[[ ! -z "$SKIP_PHALCON" ]] && exit 0

echo -e "${COLOR_SECTION}*** Phalcon ***${TEXT_RESET}"

cd "$TEMP_DIR"

# Obtain Phalcon source if not using repository method.
method=$(takeMethod "$PHALCON_INSTALL")
case "$method" in
  "git")
    echo "Git cloning Phalcon repository"
    gitBranch=$(takeRefFirst "$PHALCON_INSTALL")
    gitUrl=$(takeRefRest "$PHALCON_INSTALL")

    git clone --quiet --depth=1 -b "$gitBranch" "$gitUrl" cphalcon > /dev/null
    [[ $? -ne 0 ]] && exit 1
    cd cphalcon
    ;;
  "tarball")
    ref=$(takeRef "$PHALCON_INSTALL")
    downloadDir="$TEMP_DIR/phalcon"

    mkdir "$downloadDir"
    cd "$downloadDir"

    # The ref is a url or version.
    isUrl "$ref"
    isRefUrl=$?
    if [[ $isRefUrl -eq 0 ]]; then
      url="$ref"
    else
      version="$ref"
      url="https://github.com/phalcon/cphalcon/archive/v${version}.tar.gz"
    fi

    echo "Downloading Phalcon tarball"
    tarballFile="phacon.tarball"
    curl --silent -L -o "$tarballFile" "$url"
    [[ $? -ne 0 ]] && exit 1

    tar -xf "$tarballFile"
    [[ $? -ne 0 ]] && exit 1

    mysteryDirName=$(ls -d ./*/)
    [[ $? -ne 0 ]] && exit 1

    cd "$mysteryDirName"
    [[ $? -ne 0 ]] && exit 1
    ;;
  "repository")
    sudo apt-get install --quiet=2 "php${PHP_VERSION}-phalcon"
    [[ $? -ne 0 ]] && exit 1
    ;;
  *)
    >&2 echo "Invalid Phalcon installation method."
    exit 1
    ;;
esac

# Install Phalcon
case "$method" in
  "git" | "tarball")
    # The current directory should be the phalcon source.
    zephir --quiet install > /dev/null
    [[ $? -ne 0 ]] && exit 1
    phpExtensionEnableAll phalcon 20
    ;;
esac

printf "Phalcon extension installed.\n"
