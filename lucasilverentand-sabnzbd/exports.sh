api_key_file="${EXPORTS_APP_DATA_DIR}/.sabnzbd-api-key"
if [ ! -s "$api_key_file" ]; then
  config_file="${EXPORTS_APP_DATA_DIR}/config/sabnzbd.ini"
  existing_key=""
  if [ -f "$config_file" ]; then
    existing_key="$(awk -F= '/^[[:space:]]*api_key[[:space:]]*=/ { value = $0; sub(/^[^=]*=[[:space:]]*/, "", value); sub(/[[:space:]]+$/, "", value); print value; exit }' "$config_file")"
  fi
  case "$existing_key" in
    ''|*[!A-Za-z0-9]*) existing_key="$(openssl rand -hex 16)" ;;
  esac
  old_umask="$(umask)"
  umask 077
  mkdir -p "$EXPORTS_APP_DATA_DIR"
  printf '%s\n' "$existing_key" > "$api_key_file"
  umask "$old_umask"
fi

export LUCASILVERENTAND_SABNZBD_URL="http://lucasilverentand-sabnzbd_server_1:8080"
export LUCASILVERENTAND_SABNZBD_API_KEY="$(cat "$api_key_file")"

unset api_key_file config_file existing_key old_umask
