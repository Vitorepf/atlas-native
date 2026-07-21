#!/usr/bin/env bash
# grok-god-wave-guard.sh — v4 dual prefer + v3 fallback
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

LEDGER_V4="docs/evidence/2026-07-21-grok-24h-v4/LEDGER.md"
QUEUE_V4="docs/evidence/2026-07-21-grok-24h-v4/QUEUE.md"
LEDGER_V3="docs/evidence/2026-07-21-grok-24h-v3/LEDGER.md"
FAIL=0

say() { printf '%s\n' "$*"; }
fail() { say "GUARD FAIL: $*"; FAIL=1; }

MODE=unknown
LEDGER=""
if [[ -f "$LEDGER_V4" ]]; then
  MODE=v4
  LEDGER="$LEDGER_V4"
elif [[ -f "$LEDGER_V3" ]]; then
  MODE=v3
  LEDGER="$LEDGER_V3"
else
  fail "missing ledger v4 or v3"
fi

APP_TOUCHED=0
if git diff --name-only HEAD 2>/dev/null | rg -q '^App/Atlas/.*\.swift$'; then
  APP_TOUCHED=1
fi
if git diff --cached --name-only 2>/dev/null | rg -q '^App/Atlas/.*\.swift$'; then
  APP_TOUCHED=1
fi

if [[ "$MODE" == "v4" ]]; then
  say "mode=v4"
  [[ -f "$QUEUE_V4" ]] || fail "missing $QUEUE_V4"
  # v4: implementer may edit App during implementing wave OR idle_compress (ledger phase idle)
  if [[ "$APP_TOUCHED" -eq 1 ]]; then
    phase=$(rg '^- phase:' "$LEDGER" | head -1 | awk '{print $3}' | tr -d '\r' || true)
    active=$(rg '^- active_wave:' "$LEDGER" | head -1 | awk '{print $3}' | tr -d '\r' || true)
    # Allow: phase idle (idle compress) OR active_wave non-null (wave implement)
    if [[ "${phase:-}" != "idle" && "${active:-null}" == "null" ]]; then
      fail "App changes while phase=${phase:-?} active_wave=${active:-null} (need idle or active wave)"
    fi
  fi
elif [[ "$MODE" == "v3" && -n "$LEDGER" ]]; then
  say "mode=v3"
  phase=$(rg '^phase:' "$LEDGER" | head -1 | awk '{print $2}' | tr -d '\r' || true)
  approved=$(rg '^design_approved:' "$LEDGER" | head -1 | awk '{print $2}' | tr -d '\r' || true)
  design=$(rg '^design_path:' "$LEDGER" | head -1 | awk '{print $2}' | tr -d '\r' || true)
  say "phase=${phase:-?} approved=${approved:-?}"
  if [[ "$APP_TOUCHED" -eq 1 ]]; then
    if [[ "$phase" != "W2_implement" && "$phase" != "W3_compress" ]]; then
      fail "App changes while phase=${phase:-missing} (need W2/W3)"
    fi
    if [[ "$phase" == "W2_implement" ]]; then
      [[ "$approved" == "true" ]] || fail "W2 needs design_approved: true"
      [[ -n "$design" && "$design" != "null" && -f "$design" ]] || fail "W2 needs design file"
    fi
  fi
fi

# God-file hard fail
while IFS= read -r line; do
  case "$line" in
    *total) continue ;;
  esac
  lines=$(echo "$line" | awk '{print $1}')
  file=$(echo "$line" | awk '{print $2}')
  base=$(basename "$file")
  case "$base" in
    *View*.swift|*Shell*.swift)
      if [[ "$lines" =~ ^[0-9]+$ ]] && (( lines > 400 )); then
        fail "god-file $file has $lines lines (>400)"
      fi
      ;;
  esac
done < <(find App/Atlas -name '*.swift' -print0 | xargs -0 wc -l | sed '$d')

FORBIDDEN=$(git diff --name-only HEAD 2>/dev/null || true)
FORBIDDEN_C=$(git diff --cached --name-only 2>/dev/null || true)
echo "$FORBIDDEN"$'\n'"$FORBIDDEN_C" | rg -q '^(Sources/|App/Atlas/ConversationModel\.swift$|App/Atlas/AtlasSession\.swift$|App/Makefile$|App/project\.yml$)' \
  && fail "forbidden Core/build paths touched" || true

if git log -1 --pretty=%s 2>/dev/null | rg -qi 'collapse.*host|into host files'; then
  fail "last commit smells like host-collapse"
fi

if [[ "$FAIL" -ne 0 ]]; then
  say "See docs/prompts/grok-24h-v4-dual.md"
  exit 1
fi

say "GUARD OK (mode=$MODE)"
exit 0
