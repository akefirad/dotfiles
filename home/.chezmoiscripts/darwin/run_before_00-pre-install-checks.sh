#!/usr/bin/env bash

set -eufo pipefail


function _test_cldt_installed() {
  if ! xcode-select -p &>/dev/null; then
    echo "❌ Command Line Developer Tools not found!"
    xcode-select --install
    echo "Installing started, switch to the installation window and follow the instructions."
    echo "After the installation is complete, run this script again."
    open -a 'Install Command Line Developer Tools'
    return 1
  fi

  return 0
}


function _do_darwin_checks() {
  set +e
  trap 'set -e' RETURN

  echo "🔎 Performing macOS checks..."

  _test_cldt_installed
  _s1=$?

  if [[ $_s1 -eq 0 ]]; then
    echo "✅ All macOS checks succeeded!"
  else
    exit 1
  fi
}


_do_darwin_checks
