#!/usr/bin/env sh
set -eu

root="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
failed=0
apps=0
ports_seen="
"

fail() {
  printf 'error: %s\n' "$1" >&2
  failed=1
}

check_file_contains() {
  file="$1"
  pattern="$2"
  label="$3"

  if ! grep -Eq "$pattern" "$file"; then
    fail "$file is missing $label"
  fi
}

for app_dir in "$root"/*; do
  [ -d "$app_dir" ] || continue

  app_name="$(basename "$app_dir")"
  case "$app_name" in
    .* ) continue ;;
  esac

  apps=$((apps + 1))
  metadata="$app_dir/umbrel-app.yml"
  compose="$app_dir/docker-compose.yml"

  [ -f "$metadata" ] || fail "$app_name is missing umbrel-app.yml"
  [ -f "$compose" ] || fail "$app_name is missing docker-compose.yml"

  if [ -f "$metadata" ]; then
    check_file_contains "$metadata" '^manifestVersion:[[:space:]]*1[[:space:]]*$' 'manifestVersion: 1'
    check_file_contains "$metadata" "^id:[[:space:]]*\"?$app_name\"?[[:space:]]*$" "id matching directory name ($app_name)"
    check_file_contains "$metadata" '^name:[[:space:]]*.+' 'name'
    check_file_contains "$metadata" '^version:[[:space:]]*.+' 'version'
    check_file_contains "$metadata" '^tagline:[[:space:]]*.+' 'tagline'
    check_file_contains "$metadata" '^port:[[:space:]]*[0-9]+[[:space:]]*$' 'numeric port'

    port="$(awk -F: '/^port:[[:space:]]*[0-9]+[[:space:]]*$/ { gsub(/[[:space:]]/, "", $2); print $2; exit }' "$metadata")"
    if [ -n "$port" ]; then
      case "$port" in
        80|443|2000) fail "$metadata uses reserved Umbrel/public port $port" ;;
      esac

      if printf '%s' "$ports_seen" | grep -qx "$port"; then
        fail "$metadata uses duplicate manifest port $port"
      fi

      ports_seen="${ports_seen}${port}
"
    fi
  fi

  if [ -f "$compose" ]; then
    check_file_contains "$compose" '^services:[[:space:]]*$' 'services section'
    check_file_contains "$compose" '^[[:space:]]+app_proxy:[[:space:]]*$' 'app_proxy service'
    check_file_contains "$compose" 'APP_HOST:' 'APP_HOST'
    check_file_contains "$compose" 'APP_PORT:' 'APP_PORT'

    if grep -Eq '^[[:space:]]+image:' "$compose" &&
      grep -Ev '^[[:space:]]+image:[[:space:]]+[^[:space:]#]+:[^[:space:]#]+@sha256:[0-9a-f]{64}([[:space:]]*(#.*)?)?$' "$compose" |
      grep -Eq '^[[:space:]]+image:'; then
      fail "$compose has image references that are not pinned as tag@sha256:digest"
    fi
  fi
done

if [ "$apps" -eq 0 ]; then
  printf 'No app packages found. Store scaffold is ready.\n'
elif [ "$failed" -eq 0 ]; then
  printf 'Validated %s app package(s).\n' "$apps"
fi

exit "$failed"
