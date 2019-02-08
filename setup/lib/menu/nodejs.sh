
menu_nodejs() {
  local method=$(takeMethod "$NODEJS_INSTALL")

  # If method is not set then use the default.
  if [[ -z "$method" ]] && method=$(takeMethod "$NODEJS_DEFAULT")

  local option
  option=$("$DIALOG" \
    --backtitle "$MENU_BACKTITLE" \
    --title "Node.js Install Method" \
    --notags \
    --default-item $method \
    --menu "Choose the method to install Node.js." 9 60 2 \
      "repository" "Package Repository"
      3>&1 1>&2 2>&3)
  [[ $? -ne "$DIALOG_OK" ]] && return 0

  local methodNew=$option
  local refNew
  case "$option" in
    "repository")
      refNew=$(menuRepository NODEJS)
      [[ $? -ne 0 ]] && return 0
      ;;
    # "tarball")
    #   refNew=$(menuTarball NODEJS)
    #   [[ $? -ne 0 ]] && return 0
    #   ;;
  esac

  NODEJS_INSTALL="${methodNew}:${refNew}"
}
export -f menu_nodejs
