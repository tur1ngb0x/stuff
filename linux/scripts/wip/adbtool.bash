#!/usr/bin/env bash

readonly CACHE_MAX_AGE_MINUTES=60

readonly CACHE_DUMPSYS_PACKAGE="/tmp/adbtoolbox-dumpsys-package.cache"
readonly CACHE_DUMPSYS_APPOPS="/tmp/adbtoolbox-dumpsys-appops.cache"
readonly CACHE_CMD_PACKAGE_USER="/tmp/adbtoolbox-cmd-package-user.cache"
readonly CACHE_CMD_PACKAGE_ALL="/tmp/adbtoolbox-cmd-package-all.cache"

readonly ARRAY_PERMISSIONS=(
    # Location
    ACCESS_FINE_LOCATION
    ACCESS_COARSE_LOCATION
    ACCESS_BACKGROUND_LOCATION

    # Camera & Microphone
    CAMERA
    RECORD_AUDIO

    # Contacts
    READ_CONTACTS
    WRITE_CONTACTS

    # Calendar
    READ_CALENDAR
    WRITE_CALENDAR

    # Phone
    READ_PHONE_STATE
    READ_PHONE_NUMBERS
    CALL_PHONE
    ANSWER_PHONE_CALLS

    # Call Logs
    READ_CALL_LOG
    WRITE_CALL_LOG

    # Messaging
    SEND_SMS
    RECEIVE_SMS
    READ_SMS
    RECEIVE_MMS
    RECEIVE_WAP_PUSH

    # Health & Activity
    BODY_SENSORS
    BODY_SENSORS_BACKGROUND
    ACTIVITY_RECOGNITION

    # Bluetooth
    BLUETOOTH_SCAN
    BLUETOOTH_CONNECT
    BLUETOOTH_ADVERTISE

    # Nearby Devices
    NEARBY_WIFI_DEVICES
    UWB_RANGING

    # Media
    READ_MEDIA_AUDIO
    READ_MEDIA_VIDEO
    READ_MEDIA_IMAGES
    READ_MEDIA_VISUAL_USER_SELECTED

    # Notifications
    POST_NOTIFICATIONS

    # Scheduling
    SCHEDULE_EXACT_ALARM

    # Storage
    MANAGE_EXTERNAL_STORAGE
)

readonly ARRAY_APPOPS=(
    # Notifications
    ACCESS_NOTIFICATIONS
    USE_FULL_SCREEN_INTENT

    # Restricted access
    ACCESS_RESTRICTED_SETTINGS
    GET_USAGE_STATS

    # Services
    BIND_ACCESSIBILITY_SERVICE
    BIND_VPN_SERVICE
    START_FOREGROUND

    # Background execution
    RUN_ANY_IN_BACKGROUND
    RUN_IN_BACKGROUND
    WAKE_LOCK

    # Storage
    MANAGE_EXTERNAL_STORAGE

    # Installation
    REQUEST_INSTALL_PACKAGES

    # Scheduling
    SCHEDULE_EXACT_ALARM

    # Communication
    SEND_SMS

    # Display
    PICTURE_IN_PICTURE
    SYSTEM_ALERT_WINDOW
    WRITE_SETTINGS
)

refresh_cache_file() {
    local cache="$1"
    shift

    if find "${cache}" -mmin -"${CACHE_MAX_AGE_MINUTES}" >/dev/null 2>&1; then
        printf 'Using cache: %s\n' "${cache}"
        return
    fi

    printf 'Refreshing cache: %s\n' "${cache}"
    "$@" >| "${cache}" || return
}

refresh_cache() {
    refresh_cache_file "${CACHE_DUMPSYS_PACKAGE}" adb shell dumpsys package
    refresh_cache_file "${CACHE_DUMPSYS_APPOPS}" adb shell dumpsys appops
    refresh_cache_file "${CACHE_CMD_PACKAGE_USER}" bash -c "adb shell cmd package list packages -3 | sed 's/^package://'"
    refresh_cache_file "${CACHE_CMD_PACKAGE_ALL}" bash -c "adb shell cmd package list packages -u | sed 's/^package://'"
}

list_packages_by_permission() {
    local permission="$1"

    awk -v permission="android.permission.${permission}:" -v name="${permission}" '
        NR == FNR { user[$1]; next }
        /^ *Package \[/ { pkg=$2; gsub(/[][]/, "", pkg) }
        index($0, permission) && /granted=true/ && (pkg in user) {
            print "PERMISSION | " name " | " pkg
        }
    ' "${CACHE_CMD_PACKAGE_USER}" "${CACHE_DUMPSYS_PACKAGE}" | sort -u
}

list_permissions() {
    local permission

    for permission in "${ARRAY_PERMISSIONS[@]}"; do
        list_packages_by_permission "${permission}"
    done | column -t -s'|' -o '|'
}

list_packages_by_appops() {
    local op="$1"

    awk -v op="${op}" '
        NR == FNR { user[$1]; next }
        /^    Package / { pkg=$2; sub(/:$/, "", pkg) }
        $1 == op && ($2 == "(allow):" || $2 == "(foreground):") && (pkg in user) {
            print "APPOPS | " op " | " pkg
        }
    ' "${CACHE_CMD_PACKAGE_USER}" "${CACHE_DUMPSYS_APPOPS}" | sort -u
}

list_appops() {
    local op

    for op in "${ARRAY_APPOPS[@]}"; do
        list_packages_by_appops "${op}"
    done | column -t -s'|' -o '|'
}

list_packages() {
    local cache="$1"

    awk '
        NR == FNR {
            user[$1]
            next
        }

        /^ *Package \[/ {
            if (pkg && pkg in user)
                printf "PACKAGE | %s | %s | %s | %s | %s\n", pkg, version, install, update, installer

            pkg=$2
            gsub(/[][]/, "", pkg)
            version=""
            install=""
            update=""
            installer=""
            next
        }

        /versionName=/ {
            sub(/.*versionName=/, "")
            version=$0
            next
        }

        /lastUpdateTime=/ {
            sub(/.*lastUpdateTime=/, "")
            update=$0
            next
        }

        /installerPackageName=/ {
            sub(/.*installerPackageName=/, "")
            installer=$0
            next
        }

        /firstInstallTime=/ {
            sub(/.*firstInstallTime=/, "")
            install=$0
            next
        }

        END {
            if (pkg && pkg in user)
                printf "PACKAGE | %s | %s | %s | %s | %s\n", pkg, version, install, update, installer
        }
    ' "${cache}" "${CACHE_DUMPSYS_PACKAGE}" |
        sort -t'|' -k4,4 |
        column -t -s'|' -o '|'
}

list_packages() {
    local cache="$1"

    awk '
        function print_package() {
            if (!(pkg in user))
                return

            scope = "unknown"
            if (codepath ~ "^/data/app/")
                scope = "user"
            else if (codepath ~ "^/(system|system_ext|product|vendor|odm|apex)/")
                scope = "system"

            if (installed == "false")
                state = "uninstalled"
            else if (enabled == "0")
                state = "enabled"
            else
                state = "disabled"

            printf "PACKAGE | %s | %s | %s | %s | %s | %s | %s\n",
                scope,
                state,
                pkg,
                version,
                install,
                update,
                installer
        }

        NR == FNR {
            user[$1]
            next
        }

        /^ *Package \[/ {
            if (pkg)
                print_package()

            pkg = $2
            gsub(/[][]/, "", pkg)

            version = ""
            install = ""
            update = ""
            installer = ""
            codepath = ""
            installed = ""
            enabled = ""

            next
        }

        /versionName=/ {
            sub(/.*versionName=/, "")
            version = $0
            next
        }

        /firstInstallTime=/ {
            sub(/.*firstInstallTime=/, "")
            install = $0
            next
        }

        /lastUpdateTime=/ {
            sub(/.*lastUpdateTime=/, "")
            update = $0
            next
        }

        /installerPackageName=/ {
            sub(/.*installerPackageName=/, "")
            installer = $0
            next
        }

        /codePath=/ {
            sub(/.*codePath=/, "")
            codepath = $0
            next
        }

        /User 0:/ {
            if (match($0, /installed=(true|false)/))
                installed = substr($0, RSTART + 10, RLENGTH - 10)

            if (match($0, /enabled=[0-9]+/))
                enabled = substr($0, RSTART + 8, RLENGTH - 8)

            next
        }

        END {
            if (pkg)
                print_package()
        }
    ' "${cache}" "${CACHE_DUMPSYS_PACKAGE}" |
        sort -t'|' -k6,6 |
        column -t -s'|' -o '|'
}

list_packages() {
    local cache="$1"

    awk '
        function print_package() {
            if (!(pkg in user))
                return

            if (pkgflags ~ /UPDATED_SYSTEM_APP/)
                scope = "system_updated"
            else if (pkgflags ~ /SYSTEM/)
                scope = "system"
            else
                scope = "user"

            if (installed == "false")
                state = "uninstalled"
            else if (enabled == "0")
                state = "enabled"
            else
                state = "disabled"

            printf "PACKAGE | %s | %s | %s | %s | %s | %s | %s\n",
                pkg,
                version,
                scope,
                state,
                install,
                update,
                installer
        }

        NR == FNR {
            user[$1]
            next
        }

        /^ *Package \[/ {
            if (pkg)
                print_package()

            pkg = $2
            gsub(/[][]/, "", pkg)

            version = ""
            install = ""
            update = ""
            installer = ""
            installed = ""
            enabled = ""
            pkgflags = ""

            next
        }

        /versionName=/ {
            sub(/.*versionName=/, "")
            version = $0
            next
        }

        /firstInstallTime=/ {
            sub(/.*firstInstallTime=/, "")
            install = $0
            next
        }

        /lastUpdateTime=/ {
            sub(/.*lastUpdateTime=/, "")
            update = $0
            next
        }

        /installerPackageName=/ {
            sub(/.*installerPackageName=/, "")
            installer = $0
            next
        }

        /pkgFlags=\[/ {
            sub(/.*pkgFlags=\[/, "")
            sub(/\].*/, "")
            pkgflags = $0
            next
        }

        /User 0:/ {
            if (match($0, /installed=(true|false)/))
                installed = substr($0, RSTART + 10, RLENGTH - 10)

            if (match($0, /enabled=[0-9]+/))
                enabled = substr($0, RSTART + 8, RLENGTH - 8)

            next
        }

        END {
            if (pkg)
                print_package()
        }
    ' "${cache}" "${CACHE_DUMPSYS_PACKAGE}" | sort -t'|' -k4,4 -k5,5 -k2,2 | column -t -s'|' -o '|'
}

list_packages_user() {
    list_packages "${CACHE_CMD_PACKAGE_USER}"
}

list_packages_all() {
    list_packages "${CACHE_CMD_PACKAGE_ALL}"
}

footer() {
    cat << EOF
grep for these terms as per requirement
- 'PACKAGE'
- 'PERMISSION'
- 'APPOPS'
- 'PERMISSION_NAME'
- 'APPOPS_NAME'
- 'com.package.name'

eg.
$ adbtoolbox.bash | grep 'term'
EOF
}

main() {
    refresh_cache
    # printf '\n\n'
    # list_permissions
    # printf '\n\n'
    # list_appops
    # printf '\n\n'
    # list_packages_user
    # printf '\n\n'
    # footer
    list_packages_all
}

main "${@}"
