
menu_phalcon() {
  local method=$(takeMethod "$PHALCON_INSTALL")

  local option
  option=$("$DIALOG" \
    --backtitle "$MENU_BACKTITLE" \
    --title "Phalcon Install Method" \
    --notags \
    --default-item $method \
    --menu "Choose the method to install Phalcon." 10 60 3 \
      "repository" "Package Repository" \
      "tarball" "Tarball" \
      "git" "Git" \
      3>&1 1>&2 2>&3)
  [[ $? -ne "$DIALOG_OK" ]] && return 0

  local methodNew=$option
  local refNew
  case "$option" in
    "repository")
      refNew=$(menuRepository PHALCON)
      [[ $? -ne 0 ]] && return 0
      ;;
    "tarball")
      refNew=$(menuTarball PHALCON)
      [[ $? -ne 0 ]] && return 0
      ;;
    "git")
      refNew=$(menuGit PHALCON)
      [[ $? -ne 0 ]] && return 0
      ;;
  esac

  PHALCON_INSTALL="${methodNew}:${refNew}"
}
export -f menu_phalcon
