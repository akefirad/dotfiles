function confirm() {
  local prompt=${1:-"Are you sure?"}
  while true; do
    read answer"?$prompt "
    case $answer in
      [yes]* ) return 0;;
      * ) return 1;;
    esac
  done
}

function mvn-or-mvnw() {
  local dir="$PWD"
  while [[ ! -x "$dir/mvnw" && "$dir" != / ]]; do
    dir="${dir:h}"
  done

  if [[ -x "$dir/mvnw" ]]; then
    echo "Running \`$dir/mvnw\`..." >&2
    "$dir/mvnw" "$@"
    return $?
  fi

  command mvn "$@"
}

function gradle-or-gradlew() {
  local dir="$PWD"
  while [[ ! -x "$dir/gradlew" && "$dir" != / ]]; do
    dir="${dir:h}"
  done

  if [[ -x "$dir/gradlew" ]]; then
    echo "Running \`$dir/gradlew\`..." >&2
    "$dir/gradlew" "$@"
    return $?
  fi

  command gradle "$@"
}
