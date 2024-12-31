#!/bin/sh
echo "$0" "$@"
progdir="$(dirname "$0")"
cd "$progdir" || exit 1
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$progdir"
echo 1 >/tmp/stay_awake
trap "rm -f /tmp/stay_awake" EXIT INT TERM HUP QUIT
RES_PATH="$progdir/res"
BUTTON_LOG="$progdir/log/buttons.log"

SERVICE_NAME="dropbear"
service_on() {
    cd /mnt/SDCARD/ || exit
    if [ -f "$progdir/log/service.log" ]; then
        mv "$progdir/log/service.log" "$progdir/log/service.log.old"
    fi

    trimui_password="$(cat "$progdir/password" 2>/dev/null || true)"
    # default password is trimui
    # shellcheck disable=SC2016
    trimui_password_hash='$1$xyz$4mAm0CgEQkOzH6K/ibOvO1'
    if [ -n "$trimui_password" ]; then
        # todo: implement me
        echo "TODO: Overridie trimui password with specified password"
    else
        echo "Using default trimui password"
    fi

    # default is tina
    # shellcheck disable=SC2016
    root_password_hash='$1$xyz$aO9utGNHk.FAqgCQghNg/1'
    if [ -f "$progdir/passwordless-root" ]; then
        echo "Using passwordless root"
        # shellcheck disable=SC2016
        root_password_hash='$1$xyz$kjXWClpYD0.j9bPLUk/Ii.'
    else
        echo "Using default root password"
    fi

    if [ -f "$progdir/res/etc/passwd" ]; then
        rm -f "$progdir/res/etc/passwd" || return 1
    fi
    cp "$progdir/res/etc/passwd.template" "$progdir/res/etc/passwd"
    sed -i "s:ROOT_PASSWORD:$root_password_hash:g" "$progdir/res/etc/passwd"
    sed -i "s:TRIMUI_PASSWORD:$trimui_password_hash:g" "$progdir/res/etc/passwd"
    chmod 0664 "$progdir/res/etc/passwd" "$progdir/res/etc/group"
    chown root:root "$progdir/res/etc/passwd" "$progdir/res/etc/group"
    mount -o bind "$progdir/res/etc/passwd" /etc/passwd
    mount -o bind "$progdir/res/etc/group" /etc/group

    mkdir -p /etc/dropbear
    dropbear_bin="$progdir/bin/$SERVICE_NAME"
    if [ -f "$progdir/passwordless-root" ]; then
        ("$dropbear_bin" -R -F -E -B >"$progdir/log/service.log" 2>&1 &) &
    else
        ("$dropbear_bin" -R -F -E >"$progdir/log/service.log" 2>&1 &) &
    fi
}

service_off() {
    umount /etc/passwd
    umount /etc/group
    killall "$SERVICE_NAME"
}

monitor_buttons() {
    chmod +x "$progdir/bin/evtest"
    for dev in /dev/input/event*; do
        [ -e "$dev" ] || continue
        "$progdir/bin/evtest" "$dev" 2>&1 | while read -r line; do
            if echo "$line" | grep -q "code 17 (ABS_HAT0Y).*value -1"; then
                echo "D_PAD_UP detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 17 (ABS_HAT0Y).*value 1"; then
                echo "D_PAD_DOWN detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 16 (ABS_HAT0X).*value 1"; then
                echo "D_PAD_RIGHT detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 16 (ABS_HAT0X).*value -1"; then
                echo "D_PAD_LEFT detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 308 (BTN_WEST).*value 1"; then
                echo "BUTTON_X detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 305 (BTN_EAST).*value 1"; then
                echo "BUTTON_A detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 304 (BTN_SOUTH).*value 1"; then
                echo "BUTTON_B detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 307 (BTN_NORTH).*value 1"; then
                echo "BUTTON_Y detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 317 (BTN_THUMBL).*value 1"; then
                echo "HOTKEY_1 detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 318 (BTN_THUMBR).*value 1"; then
                echo "HOTKEY_2 detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 310 (BTN_TL).*value 1"; then
                echo "L1 detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 311 (BTN_TR).*value 1"; then
                echo "R1 detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 2 (ABS_Z).*value 255"; then
                echo "L2 detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 5 (ABS_RZ).*value 255"; then
                echo "R2 detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 316 (BTN_MODE).*value 1"; then
                echo "MENU detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 314 (BTN_SELECT).*value 1"; then
                echo "SELECT detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 315 (BTN_START).*value 1"; then
                echo "START detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 115 (KEY_VOLUMEUP).*value 1"; then
                echo "VOLUME_UP detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 114 (KEY_VOLUMEDOWN).*value 1"; then
                echo "VOLUME_DOWN detected" >>"$BUTTON_LOG"
            elif echo "$line" | grep -q "code 116 (KEY_POWER).*value 1"; then
                echo "POWER detected" >>"$BUTTON_LOG"
            fi
        done &
    done
}

wait_for_button() {
    button="$1"
    while true; do
        if grep -q "$button" "$BUTTON_LOG"; then
            break
        fi
        sleep 0.1
    done
}

wait_for_service() {
    max_counter="$1"
    counter=0

    while ! pgrep "$SERVICE_NAME" >/dev/null 2>&1; do
        counter=$((counter + 1))
        if [ "$counter" -gt "$max_counter" ]; then
            return 1
        fi
        sleep 1
    done
}

main_daemonize() {
    echo "Toggling $SERVICE_NAME..."
    if pgrep "$SERVICE_NAME"; then
        show.elf "$RES_PATH/disabling.png" 2
        echo "Stopping $SERVICE_NAME..."
        service_off
    else
        show.elf "$RES_PATH/enabling.png" 2
        echo "Starting $SERVICE_NAME..."
        service_on

        if ! wait_for_service 10; then
            show.elf "$RES_PATH/failed.png" 2
            echo "Failed to start $SERVICE_NAME!"
            return 1
        fi
    fi

    echo "Done toggling $SERVICE_NAME!"
    show.elf "$RES_PATH/done.png" 2
}

main_process() {
    if pgrep "$SERVICE_NAME"; then
        show.elf "$RES_PATH/disabling.png" 2
        echo "Stopping $SERVICE_NAME..."
        service_off
    fi

    show.elf "$RES_PATH/starting.png" &
    echo "Starting $SERVICE_NAME"
    service_on
    sleep 1

    echo "Waiting for $SERVICE_NAME to be running..."
    if ! wait_for_service 10; then
        show.elf "$RES_PATH/failed.png" 2
        echo "Failed to start $SERVICE_NAME!"
        return 1
    fi

    echo "Waiting for button press to exit..."
    if [ -f "$progdir/log/buttons.log" ]; then
        mv "$progdir/log/buttons.log" "$progdir/log/buttons.log.old"
    fi
    show.elf "$RES_PATH/press-b-to-exit.png" &
    >"$BUTTON_LOG"
    monitor_buttons

    wait_for_button "BUTTON_B"
    echo "Stopping $SERVICE_NAME..."
    show.elf "$RES_PATH/stopping.png" &
    service_off
    killall evtest
    sync
    sleep 1
    show.elf "$RES_PATH/done.png" 1
    killall show.elf
}

main() {
    if [ -f "$progdir/daemon-mode" ]; then
        main_daemonize
    else
        main_process
    fi
}

mkdir -p "$progdir/log"
if [ -f "$progdir/log/launch.log" ]; then
    mv "$progdir/log/launch.log" "$progdir/log/launch.log.old"
fi

main "$@" >"$progdir/log/launch.log" 2>&1
