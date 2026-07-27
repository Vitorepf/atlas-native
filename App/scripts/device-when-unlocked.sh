#!/usr/bin/env bash
# Instala no iPhone assim que ele for desbloqueado.
#
# `make device` exige o Developer Disk Image montado, e o CoreDevice só monta
# com o aparelho destravado. Em vez de exigir que operador e agente estejam
# na frente da máquina no mesmo instante, este script espera a janela.
#
# Uso:  bash scripts/device-when-unlocked.sh [minutos]   (padrão: 60)
set -euo pipefail

cd "$(dirname "$0")/.."

LIMITE_MIN="${1:-60}"
FIM=$(( $(date +%s) + LIMITE_MIN * 60 ))
UDID="${DEVICE_ID:-}"

if [ -z "$UDID" ]; then
  JSON="$(mktemp)"
  xcrun devicectl list devices --json-output "$JSON" >/dev/null 2>&1 || true
  UDID=$(python3 -c '
import sys, json
try: data = json.load(open(sys.argv[1]))
except Exception: sys.exit(0)
for d in data.get("result", {}).get("devices", []):
    hw, conn = d.get("hardwareProperties", {}), d.get("connectionProperties", {})
    if hw.get("platform","").lower().startswith("ios") and conn.get("pairingState") == "paired":
        print(hw.get("udid","")); break
' "$JSON" || true)
  rm -f "$JSON"
fi

[ -n "$UDID" ] || { echo "✗ nenhum iPhone pareado"; exit 1; }
echo "→ aguardando desbloqueio de $UDID (até ${LIMITE_MIN}min)"

while [ "$(date +%s)" -lt "$FIM" ]; do
  if xcrun devicectl device info lockState --device "$UDID" 2>/dev/null \
       | grep -Fq "passcodeRequired: false"; then
    echo "→ desbloqueado; instalando"
    exec make device
  fi
  sleep 20
done

echo "✗ o iPhone seguiu bloqueado por ${LIMITE_MIN}min — rode 'make device' com a tela ativa"
exit 2
