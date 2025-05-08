#!/usr/bin/env bash

set -eufo pipefail


function _disable_spotlight_shortcuts() {
  echo "ℹ️ Disabling Spotlight shortcuts..."

  if /usr/libexec/PlistBuddy ~/Library/Preferences/com.apple.symbolichotkeys.plist \
      -c "Set :AppleSymbolicHotKeys:64:enabled false" \
      -c "Set :AppleSymbolicHotKeys:65:enabled false" > /dev/null; then
      exit 0
  fi

  if [[ "$(sw_vers -productVersion)" != "15.5" ]]; then
    echo '⚠️  This script is tested only for macOS 15.5, while yours is $(sw_vers -productVersion).'
    echo 'If you experience any issues,'
    echo '  1. simply remove the added entries:'
    echo '    /usr/libexec/PlistBuddy ~/Library/Preferences/com.apple.symbolichotkeys.plist'
    echo '    -c "Delete :AppleSymbolicHotKeys:64"'
    echo '    -c "Delete :AppleSymbolicHotKeys:65"'
    echo '  2. restart the system.'
    echo '  3. disable the hotkeys in System Settings > Keyboard > Shortcuts'
    echo '  4. check the exact details of each entries by running:'
    echo '    /usr/libexec/PlistBuddy ~/Library/Preferences/com.apple.symbolichotkeys.plist'
    echo '    -c "Print :AppleSymbolicHotKeys:64"'
    echo '    -c "Print :AppleSymbolicHotKeys:65"'
  fi

  # target output for AppleSymbolicHotKeys:64
  #
  # <key>64</key>
  # <dict>
  #   <key>enabled</key>
  #   <false/>
  #   <key>value</key>
  #   <dict>
  #     <key>parameters</key>
  #     <array>
  #       <integer>32</integer>
  #       <integer>49</integer>
  #       <integer>1048576</integer>
  #     </array>
  #     <key>type</key>
  #     <string>standard</string>
  #   </dict>
  # </dict>

  /usr/libexec/PlistBuddy ~/Library/Preferences/com.apple.symbolichotkeys.plist \
    -c "Delete :AppleSymbolicHotKeys:64" \
    -c "Add :AppleSymbolicHotKeys:64:enabled bool false" \
    -c "Add :AppleSymbolicHotKeys:64:value:parameters array" \
    -c "Add :AppleSymbolicHotKeys:64:value:parameters: integer 32" \
    -c "Add :AppleSymbolicHotKeys:64:value:parameters: integer 49" \
    -c "Add :AppleSymbolicHotKeys:64:value:parameters: integer 1048576" \
    -c "Add :AppleSymbolicHotKeys:64:type string standard"


  # target output for AppleSymbolicHotKeys:65
  #
  # <key>65</key>
  # <dict>
  #   <key>enabled</key>
  #   <false/>
  #   <key>value</key>
  #   <dict>
  #     <key>parameters</key>
  #     <array>
  #       <integer>32</integer>
  #       <integer>49</integer>
  #       <integer>1572864</integer>
  #     </array>
  #     <key>type</key>
  #     <string>standard</string>
  #   </dict>
  # </dict>

  /usr/libexec/PlistBuddy ~/Library/Preferences/com.apple.symbolichotkeys.plist \
    -c "Delete :AppleSymbolicHotKeys:65" \
    -c "Add :AppleSymbolicHotKeys:65:enabled bool false" \
    -c "Add :AppleSymbolicHotKeys:65:value:parameters array" \
    -c "Add :AppleSymbolicHotKeys:65:value:parameters: integer 32" \
    -c "Add :AppleSymbolicHotKeys:65:value:parameters: integer 49" \
    -c "Add :AppleSymbolicHotKeys:65:value:parameters: integer 1572864" \
    -c "Add :AppleSymbolicHotKeys:65:type string standard"
}


_disable_spotlight_shortcuts
