#!/usr/bin/env bash
# grok-god-wave-guard.sh — prefers GOD RESTRUCTURE mission; falls back to v4 dual
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

LEDGER_RESTRUCTURE="docs/evidence/2026-07-21-grok-god-restructure/LEDGER.md"
LEDGER_V4="docs/evidence/2026-07-21-grok-24h-v4/LEDGER.md"
QUEUE_V4="docs/evidence/2026-07-21-grok-24h-v4/QUEUE.md"
LEDGER_V3="docs/evidence/2026-07-21-grok-24h-v3/LEDGER.md"
FAIL=0

MAX_ROUTE=600
MAX_ANY=2000

say() { printf '%s\n' "$*"; }
fail() { say "GUARD FAIL: $*"; FAIL=1; }

MODE=unknown
LEDGER=""
if [[ -f "$LEDGER_RESTRUCTURE" ]]; then
  MODE=restructure
  LEDGER="$LEDGER_RESTRUCTURE"
elif [[ -f "$LEDGER_V4" ]]; then
  MODE=v4
  LEDGER="$LEDGER_V4"
elif [[ -f "$LEDGER_V3" ]]; then
  MODE=v3
  LEDGER="$LEDGER_V3"
else
  fail "missing ledger restructure/v4/v3"
fi

APP_TOUCHED=0
if git diff --name-only HEAD 2>/dev/null | rg -q '^App/(Atlas|Widgets)/.*\.swift$'; then
  APP_TOUCHED=1
fi
if git diff --cached --name-only 2>/dev/null | rg -q '^App/(Atlas|Widgets)/.*\.swift$'; then
  APP_TOUCHED=1
fi

if [[ "$MODE" == "restructure" ]]; then
  say "mode=restructure (GOD code · no product WAVE)"
  phase=$(rg '^- phase:' "$LEDGER" | head -1 | awk '{print $3}' | tr -d '\r' || true)
  if [[ "$APP_TOUCHED" -eq 1 ]]; then
    case "${phase:-}" in
      act|prove|audit|boot) ;;
      god_hold)
        fail "App changes while phase=god_hold (saturated — do not invent work)"
        ;;
      *)
        fail "App changes while phase=${phase:-?} (need act|prove|audit|boot)"
        ;;
    esac
  fi
  # Product WAVE smell in staged/last subject
  if git log -1 --pretty=%s 2>/dev/null | rg -qi 'feat\(ui\): WAVE|instrument|pack wire|density peel'; then
    fail "last commit smells like product WAVE (restructure forbids)"
  fi
elif [[ "$MODE" == "v4" ]]; then
  say "mode=v4"
  [[ -f "$QUEUE_V4" ]] || fail "missing $QUEUE_V4"
  if [[ "$APP_TOUCHED" -eq 1 ]]; then
    phase=$(rg '^- phase:' "$LEDGER" | head -1 | awk '{print $3}' | tr -d '\r' || true)
    active=$(rg '^- active_wave:' "$LEDGER" | head -1 | awk '{print $3}' | tr -d '\r' || true)
    if [[ "${phase:-}" != "idle" && "${phase:-}" != "implementing" && "${phase:-}" != "w3" && "${active:-null}" == "null" ]]; then
      fail "App changes while phase=${phase:-?} active_wave=${active:-null}"
    fi
  fi
elif [[ "$MODE" == "v3" ]]; then
  say "mode=v3"
  phase=$(rg '^phase:' "$LEDGER" | head -1 | awk '{print $2}' | tr -d '\r' || true)
  if [[ "$APP_TOUCHED" -eq 1 && "$phase" != "W2_implement" && "$phase" != "W3_compress" ]]; then
    fail "App changes while phase=${phase:-missing}"
  fi
fi

while IFS= read -r line; do
  case "$line" in
    *total) continue ;;
  esac
  lines=$(echo "$line" | awk '{print $1}')
  file=$(echo "$line" | awk '{print $2}')
  [[ "$lines" =~ ^[0-9]+$ ]] || continue
  base=$(basename "$file")
  # ConversationModel is Core-adjacent — skip density fail for it
  [[ "$base" == "ConversationModel.swift" || "$base" == "AtlasSession.swift" ]] && continue

  if (( lines > MAX_ANY )); then
    fail "god-file $file has $lines lines (limit any-file=$MAX_ANY)"
    continue
  fi
  case "$base" in
    *View.swift|*Shell.swift)
      if (( lines > MAX_ROUTE )); then
        fail "route-shell $file has $lines lines (limit route=$MAX_ROUTE)"
      fi
      ;;
  esac
done < <(find App/Atlas App/Widgets -name '*.swift' -print0 2>/dev/null | xargs -0 wc -l | sed '$d')

FORBIDDEN=$(git diff --name-only HEAD 2>/dev/null || true)
FORBIDDEN_C=$(git diff --cached --name-only 2>/dev/null || true)
echo "$FORBIDDEN"$'\n'"$FORBIDDEN_C" | rg -q '^(Sources/|App/Atlas/ConversationModel\.swift$|App/Atlas/AtlasSession\.swift$|App/Makefile$|App/project\.yml$)' \
  && fail "forbidden Core/build paths touched" || true

if git log -1 --pretty=%s 2>/dev/null | rg -qi 'collapse.*host|into host files'; then
  fail "last commit smells like host-collapse"
fi

if [[ "$FAIL" -ne 0 ]]; then
  say "See docs/prompts/grok-god-restructure.md"
  exit 1
fi

say "GUARD OK (mode=$MODE density route<=$MAX_ROUTE any<=$MAX_ANY)"
exit 0
