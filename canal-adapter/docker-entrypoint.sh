#!/usr/bin/env bash
set -eo pipefail

_main() {
    if [ -n "$TZ" ]; then
        ( ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime && echo "$TZ" > /etc/timezone ) || true
    fi
    chown -R admin:admin /home/admin/logs || true
    chown -R admin:admin /home/admin/conf || true
    exec gosu admin /home/admin/canal-adapter/bin/startup.sh "$@"
}

_main "$@"
