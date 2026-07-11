#!/bin/sh
set -eu

config_dir=/crafty/app/config

if [ ! -f "$config_dir/crafty.sqlite" ]; then
  if [ -z "${CRAFTY_ADMIN_PASSWORD:-}" ]; then
    echo "CRAFTY_ADMIN_PASSWORD is required" >&2
    exit 1
  fi

  if [ -z "$(find "$config_dir" -mindepth 1 ! -name .gitkeep -print -quit)" ]; then
    cp -R /crafty/app/config_original/. "$config_dir/"
  fi

  python3 - "$config_dir/default.json" "$CRAFTY_ADMIN_PASSWORD" <<'PY'
import json
import sys

path, password = sys.argv[1:]
with open(path, "w", encoding="utf-8") as default_file:
    json.dump({"username": "admin", "password": password}, default_file)
PY

  for data_dir in /crafty/backups /crafty/logs /crafty/servers "$config_dir" /crafty/import; do
    chgrp -R root "$data_dir"
    chmod -R g+rwX "$data_dir"
    find "$data_dir" -type d -exec chmod g+s {} +
  done
fi

exec /crafty/docker_launcher.sh "$@"
