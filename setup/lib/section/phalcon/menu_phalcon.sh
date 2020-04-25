
menu_phalcon() {
  local project=PHALCON
  local install="${PHALCON_INSTALLER:-$PHALCON_DEFAULT}"
  local method=$(takeMethod "$install")

  local option
  option=$("$DIALOG" \
    --backtitle "$MENU_BACKTITLE" \
    --title "Phalcon Installer method" \
    --notags \
    --default-item $method \
    --menu "Choose the method for installing Phalcon." 12 60 5 \
      clear "** Clear Installer **" \
      git "Git" \
      pecl "Pecl" \
      repository "Package Repository" \
      tarball "Tarball" \
      3>&1 1>&2 2>&3)
  [[ $? -ne "$DIALOG_OK" ]] && return 0

  local methodNew=$option
  local refNew
  case "$option" in
    "git")
      refNew=$(menuGit $project "$install")
      [[ $? -ne 0 ]] && return 0
      ;;
    "pecl")
      refNew=$(menuPecl $project "$install")
      [[ $? -ne 0 ]] && return 0
      ;;
    "repository")
      refNew=$(menuRepository $project "$install")
      [[ $? -ne 0 ]] && return 0
      ;;
    "tarball")
      refNew=$(menuTarball $project "$install")
      [[ $? -ne 0 ]] && return 0
      ;;
  esac

  if [[ "$option" == "clear" ]]; then
    unset PHALCON_INSTALLER
  else
    PHALCON_INSTALLER="${methodNew}:${refNew}"
  fi
}
export -f menu_phalcon
