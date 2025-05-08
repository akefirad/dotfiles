#!/bin/sh

set -eufo pipefail


function _get_os() {
  local _UNAME
  _UNAME="$(command uname -a)"
  local _OS
  case "${_UNAME}" in
    Linux\ *)   _OS=linux   ;;
    Darwin\ *)  _OS=darwin  ;;
    SunOS\ *)   _OS=sunos   ;;
    FreeBSD\ *) _OS=freebsd ;;
    OpenBSD\ *) _OS=openbsd ;;
    AIX\ *)     _OS=aix     ;;
    CYGWIN* | MSYS* | MINGW*) _OS=win ;;
  esac
  echo "${_OS-}"
}


function _test_full_disk_access() {
  # TODO: Does it have to be Safari?
  if defaults write com.apple.Safari TestFullDiskAccess -bool true 2>/dev/null; then
    defaults delete com.apple.Safari TestFullDiskAccess 2>/dev/null || true
    return 0
  fi
  echo "❌ Terminal does not have full disk access."
  echo "Please grant full disk access to Terminal in System Preferences > Privacy & Security > Full Disk Access"
  open "x-apple.systempreferences:com.apple.preference.security"    
  return 1
}


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

  local _OS
  _OS="$(_get_os)"

  if [[ "$_OS" != "darwin" ]]; then
    return 0
  fi

  echo "🔎 Detected '$_OS' operating system, checking..."

  _test_full_disk_access
  _s1=$?

  _test_cldt_installed
  _s2=$?

  if [[ $_s1 -eq 0 && $_s2 -eq 0 ]]; then
    echo "✅ All '$_OS' checks succeeded!"
  else
    exit 1
  fi
}


_do_darwin_checks

git clone https://github.com/akefirad/dotfiles.git ~/.dotfiles

~/.dotfiles/install.sh
