
menu_zparser() {
  local method=$(takeMethod "$ZPARSER_INSTALL")

  local option
  option=$("$DIALOG" \
    --backtitle "$MENU_BACKTITLE" \
    --title "zephir_parser Install Method" \
    --notags \
    --default-item $method \
    --cancel-button "Return to Customize" \
    --menu "Choose the method to install zephir_parser." 10 60 2 \
      "tarball" "Tarball" \
      "git" "Git" \
      3>&1 1>&2 2>&3)
  [[ $? -ne "$DIALOG_OK" ]] && return 0

  local methodNew=$option
  local refNew
  case "$option" in
    "tarball")
      refNew=$(menuTarball ZPARSER)
      [[ $? -ne 0 ]] && return 0
      ;;
    "git")
      refNew=$(menuGit ZPARSER)
      [[ $? -ne 0 ]] && return 0
      ;;
  esac

  ZPARSER_INSTALL="${methodNew}:${refNew}"
}
export -f menu_zparser
