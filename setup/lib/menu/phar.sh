
menuPhar() {
  local project=$1
  local installer=$2

  local nameVar=MENU_${project}_NAME
  local versionsVar=MENU_${project}_VERSIONS
  local examplesVar=MENU_${project}_PHAR_EXAMPLES
  local defaultVersionVar=${project}_DEFAULT_VERSION

  local msg
  read -r -d '' msg << EOM
Enter either an official ${!nameVar} release version or the URL of a ${!nameVar} phar.

See ${!versionsVar}

Examples; ${!examplesVar}
EOM

  # If the installation method was something other than this
  # then the defaults for this method will need to be used instead.
  local method=$(takeMethod "$installer")
  [[ "$method" = phar ]] && local ref=$(takeRef "$installer") || local ref="${!defaultVersionVar}"

  local numExamples=$(echo -n "${!examplesVar}" | grep -c '^')
  local totalLines=$(($numExamples + 11))
  local input
  input=$("$DIALOG" \
    --backtitle "$MENU_BACKTITLE" \
    --title "Choose ${!nameVar} version" \
    --cancel-button "Return to Customize" \
    --inputbox "$msg" $totalLines 110 \
      "$ref" \
      3>&1 1>&2 2>&3)
  ret=$?
  [[ $ret -ne "$DIALOG_OK" ]] && return 1

  # Trim whitespace
  input="${input#"${input%%[![:space:]]*}"}"
  input="${input%"${input##*[![:space:]]}"}"
  # Don't allow empty input
  [[ -z "$input" ]] && return 1

  echo "$input"
  return 0
}
export -f menuPhar
