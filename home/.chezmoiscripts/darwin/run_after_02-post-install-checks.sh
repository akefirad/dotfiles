#!/usr/bin/env bash

typeset -a _apps_needing_permissions


function _test_full_disk_access() {
  if ! ls ~/Library/Mail &>/dev/null; then
    echo "❌ Terminal does not have full disk access."
    echo "Please grant full disk access to Terminal in System Preferences > Privacy & Security > Full Disk Access"
    open "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
    return 1
  fi
}


_test_full_disk_access


function _check_screen_recording() {
    local app_name="$1"

    if [[ ! -d "/Applications/${app_name}.app" && ! -d "$HOME/Applications/${app_name}.app" ]]; then
        echo "❌ ${app_name} is not installed"
        return 0
    fi

    local bundle_id=$(osascript -e "id of app \"${app_name}\"" 2>/dev/null)
    if [ -z "$bundle_id" ]; then
        echo "❌ Could not determine bundle ID for ${app_name}"
        return 0
    fi

    local system_screen_status=$(sqlite3 "/Library/Application Support/com.apple.TCC/TCC.db" \
        "SELECT auth_value FROM access WHERE service='kTCCServiceScreenCapture' AND client='${bundle_id}';" 2>/dev/null)
    local user_screen_status=$(sqlite3 "$HOME/Library/Application Support/com.apple.TCC/TCC.db" \
        "SELECT auth_value FROM access WHERE service='kTCCServiceScreenCapture' AND client='${bundle_id}';" 2>/dev/null)

    if [[ $system_screen_status == "2" ]] || [[ $user_screen_status == "2" ]]; then
        echo "✅ ${app_name} has screen recording access"
    else
        echo "❌ ${app_name} does not have screen recording access"
        _apps_needing_permissions+=("$app_name")
    fi
}


echo "🔎 Checking screen recording permissions..."
_check_screen_recording "Slack"
_check_screen_recording "zoom.us"
_check_screen_recording "Immersed"
_check_screen_recording "Google Chrome"
_check_screen_recording "Brave Browser"


if (( ${#_apps_needing_permissions[@]} > 0 )); then
    echo "⚙️ To grant screen recording access:"
    echo "  1️⃣  Open System Settings"
    echo "  2️⃣  Go to Privacy & Security > Screen & System Audio Recording"
    echo "  3️⃣  Enable the following apps:"
    for app in "${_apps_needing_permissions[@]}"; do
        echo "    📲 ${app}"
    done

    open "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture"
fi
