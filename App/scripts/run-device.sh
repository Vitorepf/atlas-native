#!/usr/bin/env bash
# Builda, instala e abre o app no iPhone físico. Uso:
#   bash scripts/run-device.sh [BUNDLE] [SCHEME] [PROJECT]
#   DEVICE_ID=<udid> bash scripts/run-device.sh   # força um device específico
set -euo pipefail

BUNDLE="${1:-com.vitor.atlas.native}"
SCHEME="${2:-Atlas}"
PROJECT="${3:-Atlas.xcodeproj}"

# 1. Device: usa DEVICE_ID se dado, senão auto-detecta o 1º iPhone conectado.
UDID="${DEVICE_ID:-}"
if [ -z "$UDID" ]; then
  DEVICES_JSON="$(mktemp)"
  xcrun devicectl list devices --json-output "$DEVICES_JSON" >/dev/null 2>&1 || true
  UDID=$(python3 -c '
import sys, json
try:
    data = json.load(open(sys.argv[1]))
except Exception:
    sys.exit(0)
for dev in data.get("result", {}).get("devices", []):
    conn = dev.get("connectionProperties", {})
    hw = dev.get("hardwareProperties", {})
    if hw.get("platform", "").lower().startswith("ios") and conn.get("pairingState") == "paired":
        print(hw.get("udid", "")); break
' "$DEVICES_JSON" || true)
  rm -f "$DEVICES_JSON"
fi

if [ -z "$UDID" ]; then
  echo "✗ Nenhum iPhone pareado encontrado."
  echo "  1ª vez: conecte via cabo, confie no Mac, e rode Cmd+R no Xcode (make open)."
  echo "  Liste devices: xcrun devicectl list devices"
  exit 1
fi
echo "→ iPhone físico pareado encontrado"

# 2. Build (assinatura automática, provisioning sob demanda).
DERIVED="$(mktemp -d)"
xcodebuild -quiet -project "$PROJECT" -scheme "$SCHEME" -configuration Debug \
  -destination "id=$UDID" -allowProvisioningUpdates \
  -derivedDataPath "$DERIVED" build

# 3. Localiza o .app e instala + abre.
APP="$(/usr/bin/find "$DERIVED/Build/Products" -maxdepth 2 -name '*.app' | head -1)"
if [ -z "$APP" ]; then echo "✗ .app não encontrado no build"; exit 1; fi
echo "→ app: $APP"

xcrun devicectl device install app --device "$UDID" "$APP"
xcrun devicectl device process launch --device "$UDID" "$BUNDLE"
echo "✓ Atlas rodando no iPhone."
