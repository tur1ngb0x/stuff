#!/usr/bin/env bash

#######################################################################################################################
# LOCATION
#######################################################################################################################
# list apps
adb shell '
for pkg in $(cmd package list packages -3 | sed "s/^package://"); do
    granted="$(dumpsys package "${pkg}" | grep "granted=true" | grep -E "ACCESS_FINE_LOCATION|ACCESS_COARSE_LOCATION|ACCESS_BACKGROUND_LOCATION")"

    if [ -n "${granted}" ]; then
        echo "# -------- ${pkg} -------- #"
        echo "${granted}"
        echo
    fi
done
'

# remove permission
adb shell '
for pkg in $(cmd package list packages -3 | sed "s/^package://"); do
    echo "# -------- ${pkg} -------- #"

    pm revoke "${pkg}" android.permission.ACCESS_FINE_LOCATION
    pm revoke "${pkg}" android.permission.ACCESS_COARSE_LOCATION
    pm revoke "${pkg}" android.permission.ACCESS_BACKGROUND_LOCATION
done
'

#######################################################################################################################
# MICROPHONE
#######################################################################################################################
# list apps
adb shell '
for pkg in $(cmd package list packages -3 | sed "s/^package://"); do
    granted="$(dumpsys package "${pkg}" | grep "granted=true" | grep "RECORD_AUDIO")"

    if [ -n "${granted}" ]; then
        echo "# -------- ${pkg} -------- #"
        echo "${granted}"
        echo
    fi
done
'

# remove permission
adb shell '
for pkg in $(cmd package list packages -3 | sed "s/^package://"); do
    echo "# -------- ${pkg} -------- #"

    pm revoke "${pkg}" android.permission.RECORD_AUDIO
done
'

#######################################################################################################################
# CAMERA
#######################################################################################################################
# list apps
adb shell '
for pkg in $(cmd package list packages -3 | sed "s/^package://"); do
    granted="$(dumpsys package "${pkg}" | grep "granted=true" | grep "CAMERA")"

    if [ -n "${granted}" ]; then
        echo "# -------- ${pkg} -------- #"
        echo "${granted}"
        echo
    fi
done
'

# remove permission
adb shell '
for pkg in $(cmd package list packages -3 | sed "s/^package://"); do
    echo "# -------- ${pkg} -------- #"

    pm revoke "${pkg}" android.permission.CAMERA
done
'

#######################################################################################################################
# DRAW OVER OTHER APPS
#######################################################################################################################
# list apps
adb shell '
for pkg in $(cmd package list packages -3 | sed "s/^package://"); do
    mode="$(appops get "${pkg}" SYSTEM_ALERT_WINDOW 2>/dev/null | grep "SYSTEM_ALERT_WINDOW")"

    if echo "${mode}" | grep -q "allow"; then
        echo "# -------- ${pkg} -------- #"
        echo "${mode}"
        echo
    fi
done
'

# remove permission
adb shell '
for pkg in $(cmd package list packages -3 | sed "s/^package://"); do
    echo "# -------- ${pkg} -------- #"

    appops set "${pkg}" SYSTEM_ALERT_WINDOW deny
done
'

#######################################################################################################################
# NOTIFICATION ACCESS
#######################################################################################################################
# list apps
adb shell '
for pkg in $(cmd package list packages -3 | sed "s/^package://"); do
    mode="$(appops get "${pkg}" ACCESS_NOTIFICATIONS 2>/dev/null | grep "ACCESS_NOTIFICATIONS")"

    if echo "${mode}" | grep -q "allow"; then
        echo "# -------- ${pkg} -------- #"
        echo "${mode}"
        echo
    fi
done
'

# remove permission
adb shell '
for pkg in $(cmd package list packages -3 | sed "s/^package://"); do
    echo "# -------- ${pkg} -------- #"

    appops set "${pkg}" ACCESS_NOTIFICATIONS deny
done
'

#######################################################################################################################
# PICTURE IN PICTURE
#######################################################################################################################
# list apps
adb shell '
for pkg in $(cmd package list packages -3 | sed "s/^package://"); do
    mode="$(appops get "${pkg}" PICTURE_IN_PICTURE 2>/dev/null | grep "PICTURE_IN_PICTURE")"

    if echo "${mode}" | grep -q "allow"; then
        echo "# -------- ${pkg} -------- #"
        echo "${mode}"
        echo
    fi
done
'

# remove permission
adb shell '
for pkg in $(cmd package list packages -3 | sed "s/^package://"); do
    echo "# -------- ${pkg} -------- #"

    appops set "${pkg}" PICTURE_IN_PICTURE deny
done
'

#######################################################################################################################
# MODIFY SYSTEM SETTINGS
#######################################################################################################################
# list apps
adb shell '
for pkg in $(cmd package list packages -3 | sed "s/^package://"); do
    mode="$(appops get "${pkg}" WRITE_SETTINGS 2>/dev/null | grep "WRITE_SETTINGS")"

    if echo "${mode}" | grep -q "allow"; then
        echo "# -------- ${pkg} -------- #"
        echo "${mode}"
        echo
    fi
done
'

# remove permission
adb shell '
for pkg in $(cmd package list packages -3 | sed "s/^package://"); do
    echo "# -------- ${pkg} -------- #"

    appops set "${pkg}" WRITE_SETTINGS deny
done
'

#######################################################################################################################
# RUN IN BACKGROUND
#######################################################################################################################
# list apps
adb shell '
for pkg in $(cmd package list packages -3 | sed "s/^package://"); do
    mode="$(appops get "${pkg}" RUN_IN_BACKGROUND 2>/dev/null | grep "RUN_IN_BACKGROUND")"

    if echo "${mode}" | grep -q "allow"; then
        echo "# -------- ${pkg} -------- #"
        echo "${mode}"
        echo
    fi
done
'

# remove permission
adb shell '
for pkg in $(cmd package list packages -3 | sed "s/^package://"); do
    echo "# -------- ${pkg} -------- #"

    appops set "${pkg}" RUN_IN_BACKGROUND deny
done
'

#######################################################################################################################
# RUN ANY IN BACKGROUND
#######################################################################################################################
# list apps
adb shell '
for pkg in $(cmd package list packages -3 | sed "s/^package://"); do
    mode="$(appops get "${pkg}" RUN_ANY_IN_BACKGROUND 2>/dev/null | grep "RUN_ANY_IN_BACKGROUND")"

    if echo "${mode}" | grep -q "allow"; then
        echo "# -------- ${pkg} -------- #"
        echo "${mode}"
        echo
    fi
done
'

# remove permission
adb shell '
for pkg in $(cmd package list packages -3 | sed "s/^package://"); do
    echo "# -------- ${pkg} -------- #"

    appops set "${pkg}" RUN_ANY_IN_BACKGROUND deny
done
'

#######################################################################################################################
# START FOREGROUND
#######################################################################################################################
# list apps
adb shell '
for pkg in $(cmd package list packages -3 | sed "s/^package://"); do
    mode="$(appops get "${pkg}" START_FOREGROUND 2>/dev/null | grep "START_FOREGROUND")"

    if echo "${mode}" | grep -q "allow"; then
        echo "# -------- ${pkg} -------- #"
        echo "${mode}"
        echo
    fi
done
'

# remove permission
adb shell '
for pkg in $(cmd package list packages -3 | sed "s/^package://"); do
    echo "# -------- ${pkg} -------- #"

    appops set "${pkg}" START_FOREGROUND deny
done
'

#######################################################################################################################
# WAKE LOCK
#######################################################################################################################
# list apps
adb shell '
for pkg in $(cmd package list packages -3 | sed "s/^package://"); do
    mode="$(appops get "${pkg}" WAKE_LOCK 2>/dev/null | grep "WAKE_LOCK")"

    if echo "${mode}" | grep -q "allow"; then
        echo "# -------- ${pkg} -------- #"
        echo "${mode}"
        echo
    fi
done
'

# remove permission
adb shell '
for pkg in $(cmd package list packages -3 | sed "s/^package://"); do
    echo "# -------- ${pkg} -------- #"

    appops set "${pkg}" WAKE_LOCK deny
done
'

#######################################################################################################################
# MANAGE ALL FILES
#######################################################################################################################
# list apps
adb shell '
for pkg in $(cmd package list packages -3 | sed "s/^package://"); do
    mode="$(appops get "${pkg}" MANAGE_EXTERNAL_STORAGE 2>/dev/null | grep "MANAGE_EXTERNAL_STORAGE")"

    if echo "${mode}" | grep -q "allow"; then
        echo "# -------- ${pkg} -------- #"
        echo "${mode}"
        echo
    fi
done
'

# remove permission
adb shell '
for pkg in $(cmd package list packages -3 | sed "s/^package://"); do
    echo "# -------- ${pkg} -------- #"

    appops set "${pkg}" MANAGE_EXTERNAL_STORAGE deny
done
'

#######################################################################################################################
# POST NOTIFICATIONS
#######################################################################################################################
# list apps
adb shell '
for pkg in $(cmd package list packages -3 | sed "s/^package://"); do
    granted="$(dumpsys package "${pkg}" | grep "granted=true" | grep "POST_NOTIFICATIONS")"

    if [ -n "${granted}" ]; then
        echo "# -------- ${pkg} -------- #"
        echo "${granted}"
        echo
    fi
done
'

# remove permission
adb shell '
for pkg in $(cmd package list packages -3 | sed "s/^package://"); do
    echo "# -------- ${pkg} -------- #"

    pm revoke "${pkg}" android.permission.POST_NOTIFICATIONS
done
'
