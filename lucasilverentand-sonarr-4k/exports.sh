api_key_file="${EXPORTS_APP_DATA_DIR}/.sonarr-4k-api-key"
if [ ! -s "$api_key_file" ]; then
  config_file="${EXPORTS_APP_DATA_DIR}/config/config.xml"
  existing_key=""
  if [ -f "$config_file" ]; then
    existing_key="$(sed -n 's:.*<ApiKey>\([^<]*\)</ApiKey>.*:\1:p' "$config_file" | head -n 1)"
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

export LUCASILVERENTAND_SONARR_4K_URL="http://lucasilverentand-sonarr-4k_server_1:8989"
export LUCASILVERENTAND_SONARR_4K_API_KEY="$(cat "$api_key_file")"

unset api_key_file config_file existing_key old_umask
