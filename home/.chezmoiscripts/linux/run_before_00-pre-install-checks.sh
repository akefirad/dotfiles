#!/usr/bin/env bash

set -eufo pipefail


function _test_foo() {
  return 0
}


function _do_linux_checks() {
  set +e
  trap 'set -e' RETURN

  echo "🔎 Performing Linux checks..."

  _test_foo
  _s1=$?

  if [[ $_s1 -eq 0 ]]; then
    echo "✅ All Linux checks succeeded!"
  else
    exit 1
  fi
}


_do_linux_checks
