#!/usr/bin/env bash
set -eo pipefail

_main() {
    if [ -n "$TZ" ]; then
        ( ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime && echo "$TZ" > /etc/timezone ) || true
    fi


    exec gosu admin /home/admin/canal-adapter/bin/startup.sh "$@"
}

_main "$@"
