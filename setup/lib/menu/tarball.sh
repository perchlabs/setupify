
menuTarball() {
  local project=$1
  local installer=$2

  local nameVar=MENU_${project}_NAME
  local versionsVar=MENU_${project}_VERSIONS
  local examplesVar=MENU_${project}_TARBALL_EXAMPLES
  local defaultVersionVar=${project}_DEFAULT_VERSION

  local msg="
Enter either an official ${!nameVar} release version or the URL of a ${!nameVar} tarball.

See ${!versionsVar}

Examples; ${!examplesVar}
"

  # If the installation method was something other than this
  # then the defaults for this method will need to be used instead.
  local method=$(takeMethod "$installer")
  [[ "$method" = tarball ]] && local ref=$(takeRef "$installer") || local ref="${!defaultVersionVar}"

  local numExamples=$(echo -n "${!examplesVar}" | grep -c '^')
  local totalLines=$(($numExamples + 12))
  local input
  input=$("$DIALOG" \
    --backtitle "$MENU_BACKTITLE" \
    --title "Choose ${!nameVar} version or tarball URL" \
    --inputbox "$msg" $totalLines 110 \
      "$ref" \
      3>&1 1>&2 2>&3)
  [[ $? -ne "$DIALOG_OK" ]] && return 1

  # Trim whitespace
  input="${input#"${input%%[![:space:]]*}"}"
  input="${input%"${input##*[![:space:]]}"}"
  # Don't allow empty input
  [[ -z "$input" ]] && return 1

  echo "$input"
}
export -f menuTarball
