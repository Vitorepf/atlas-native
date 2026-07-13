#!/usr/bin/env bash
# Executa AtlasDeviceProof no primeiro iPhone pareado e exporta attachments.
# Uso: DEVICE_ID=<udid> bash scripts/run-device-proof.sh [SCHEME] [PROJECT]
set -euo pipefail

SCHEME="${1:-Atlas}"
PROJECT="${2:-Atlas.xcodeproj}"
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
  echo "✗ Nenhum iPhone pareado disponível para DeviceProof."
  exit 1
fi

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
STAMP="$(date +%F)"
RESULT="${RESULT_PATH:-$ROOT/App/build/AtlasDeviceProof.xcresult}"
EVIDENCE="${EVIDENCE_PATH:-$ROOT/docs/evidence/$STAMP/device-proof}"

rm -rf "$RESULT" "$EVIDENCE"
mkdir -p "$(dirname "$RESULT")" "$EVIDENCE"

echo "→ DeviceProof no iPhone físico"
xcodebuild test -quiet -project "$PROJECT" -scheme "$SCHEME" -configuration Debug \
  -destination "platform=iOS,id=$UDID" -allowProvisioningUpdates \
  -test-timeouts-enabled YES -default-test-execution-time-allowance 900 \
  -resultBundlePath "$RESULT" \
  -only-testing:AtlasDeviceProof/AtlasDeviceProofTests/testToolExecutionAndPersistentCockpit

xcrun xcresulttool export attachments --path "$RESULT" --output-path "$EVIDENCE"
echo "✓ DeviceProof verde; evidências em $EVIDENCE"
