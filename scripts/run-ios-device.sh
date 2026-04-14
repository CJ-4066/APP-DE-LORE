#!/bin/zsh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MOBILE_DIR="$ROOT_DIR/apps/mobile"

detect_lan_ip() {
  local candidate=""
  local fallback=""

  is_private_lan_ip() {
    local ip="$1"
    [[ "$ip" == 10.* || "$ip" == 192.168.* ]] && return 0

    if [[ "$ip" =~ ^172\.([1][6-9]|2[0-9]|3[0-1])\. ]]; then
      return 0
    fi

    return 1
  }

  for iface in en0 en1 en2 en3 en4 en5; do
    candidate="$(ipconfig getifaddr "$iface" 2>/dev/null || true)"
    if [[ -n "$candidate" ]]; then
      if is_private_lan_ip "$candidate"; then
        echo "$candidate"
        return 0
      fi

      if [[ -z "$fallback" && "$candidate" != 169.254.* && "$candidate" != 127.* ]]; then
        fallback="$candidate"
      fi
    fi
  done

  candidate="$(
    ifconfig 2>/dev/null | awk '
      /^[a-z0-9]+: flags=/ { iface=$1 }
      $1 == "inet" && $2 ~ /^(10|172|192)\./ { print $2; exit }
    '
  )"

  if [[ -n "$candidate" ]]; then
    echo "$candidate"
    return 0
  fi

  if [[ -n "$fallback" ]]; then
    echo "$fallback"
    return 0
  fi

  return 1
}

if [[ -n "${API_BASE_URL:-}" ]]; then
  BASE_URL="$API_BASE_URL"
else
  LAN_IP="$(detect_lan_ip || true)"
  if [[ -z "$LAN_IP" ]]; then
    echo "No pude detectar la IP LAN de esta Mac. Exporta API_BASE_URL manualmente."
    echo "Ejemplo: API_BASE_URL=http://192.168.1.158:4000 npm run mobile:ios:device"
    exit 1
  fi

  BASE_URL="http://$LAN_IP:4000"
fi

if ! lsof -nP -iTCP:4000 -sTCP:LISTEN >/dev/null 2>&1; then
  echo "La API no esta escuchando en el puerto 4000."
  echo "Levanta primero el backend con: npm run dev:api"
  exit 1
fi

if [[ -n "${IOS_DEVICE_ID:-}" ]]; then
  DEVICE_ID="$IOS_DEVICE_ID"
else
  DEVICE_ID="$(
    flutter devices --machine 2>/dev/null \
      | node -e '
const fs = require("fs");
const raw = fs.readFileSync(0, "utf8").trim();
if (!raw) {
  process.exit(0);
}

const devices = JSON.parse(raw);
const match = devices.find((device) => {
  const platform = String(device.targetPlatform || "").toLowerCase();
  const name = String(device.name || "");
  return platform === "ios" && !name.includes("Simulator");
});

if (match?.id) {
  process.stdout.write(String(match.id));
}
'
  )"
fi

if [[ -z "$DEVICE_ID" ]]; then
  echo "No encontre un iPhone fisico conectado."
  echo "Conecta y desbloquea el iPhone, luego vuelve a ejecutar este comando."
  exit 1
fi

echo "Usando dispositivo: $DEVICE_ID"
echo "Usando API: $BASE_URL"

cd "$MOBILE_DIR"
flutter run --release -d "$DEVICE_ID" --dart-define="API_BASE_URL=$BASE_URL"
