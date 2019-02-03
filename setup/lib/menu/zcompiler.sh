
menu_zcompiler() {
  local msg
  read -r -d '' msg << EOM
Choose the method for installing Zephir.
 _____              __    _
/__  /  ___  ____  / /_  (_)____
  / /  / _ \/ __ \/ __ \/ / ___/
 / /__/  __/ /_/ / / / / / /
/____/\___/ .___/_/ /_/_/_/
         /_/
EOM

  local method=$(takeMethod "$ZCOMPILER_INSTALL")
  local option
  option=$("$DIALOG" \
    --backtitle "$MENU_BACKTITLE" \
    --title "Zephir Install Method" \
    --notags \
    --no-collapse \
    --default-item $method \
    --cancel-button "Return to Overview" \
    --menu "$msg" 16 80 3 \
      "phar" "Phar" \
      "tarball" "Tarball" \
      "git" "Git" \
      3>&1 1>&2 2>&3)
  [[ $? -ne "$DIALOG_OK" ]] && return 0

  local methodNew=$option
  local refNew
  case "$option" in
    "phar")
      refNew=$(menuPhar ZCOMPILER)
      [[ $? -ne 0 ]] && return 0
      ;;
    "tarball")
      refNew=$(menuTarball ZCOMPILER)
      [[ $? -ne 0 ]] && return 0
      ;;
    "git")
      refNew=$(menuGit ZCOMPILER)
      [[ $? -ne 0 ]] && return 0
      ;;
  esac

  ZCOMPILER_INSTALL="${methodNew}:${refNew}"
}
export -f menu_zcompiler
