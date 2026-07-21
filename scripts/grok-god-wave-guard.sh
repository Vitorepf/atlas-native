#!/usr/bin/env bash
# grok-god-wave-guard.sh — checagens mecânicas da missão GOD WAVES v3.1
# Exit 0 = ok para commit de produto. Exit 1 = hard fail.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

LEDGER="docs/evidence/2026-07-21-grok-24h-v3/LEDGER.md"
FAIL=0

say() { printf '%s\n' "$*"; }
fail() { say "GUARD FAIL: $*"; FAIL=1; }

if [[ ! -f "$LEDGER" ]]; then
  fail "missing $LEDGER — create v3.1 ledger before product commits"
else
  phase=$(rg -n '^phase:' "$LEDGER" | head -1 | sed 's/.*phase:[[:space:]]*//' | tr -d '\r' || true)
  active=$(rg -n '^active_wave:' "$LEDGER" | head -1 | sed 's/.*active_wave:[[:space:]]*//' | tr -d '\r' || true)
  approved=$(rg -n '^design_approved:' "$LEDGER" | head -1 | sed 's/.*design_approved:[[:space:]]*//' | tr -d '\r' || true)
  design=$(rg -n '^design_path:' "$LEDGER" | head -1 | sed 's/.*design_path:[[:space:]]*//' | tr -d '\r' || true)
  say "ledger phase=$phase active_wave=$active design_approved=$approved"

  case "${phase:-}" in
    idle|W0_council|W1_design|W2_implement|W3_compress) ;;
    *) fail "invalid or missing phase in ledger" ;;
  esac

  # Product code staged/changed?
  if git diff --cached --name-only 2>/dev/null | rg -q '^App/Atlas/.*\.swift$' \
    || git diff --name-only 2>/dev/null | rg -q '^App/Atlas/.*\.swift$'; then
    if [[ "$phase" != "W2_implement" && "$phase" != "W3_compress" ]]; then
      fail "App/Atlas Swift changes while phase=$phase (only W2/W3 allowed)"
    fi
    if [[ "$phase" == "W2_implement" ]]; then
      if [[ "${approved}" != "true" ]]; then
        fail "W2 requires design_approved: true"
      fi
      if [[ -z "${design}" || "${design}" == "null" || ! -f "${design}" ]]; then
        fail "W2 requires design_path file to exist on disk"
      fi
    fi
  fi
fi

# Hard fail god-files
while IFS= read -r line; do
  lines=${line%% *}
  file=${line#* }
  base=$(basename "$file")
  if [[ "$base" == *View*.swift || "$base" == *Shell*.swift ]]; then
    if [[ "$lines" -gt 400 ]]; then
      fail "god-file $file has $lines lines (>400)"
    fi
  fi
done < <(find App/Atlas -name '*.swift' -print0 | xargs -0 wc -l | sed '$d')

# Forbidden paths touched in working tree / index
if git diff --name-only HEAD 2>/dev/null | rg -q '^(Sources/|App/Atlas/ConversationModel\.swift$|App/Atlas/AtlasSession\.swift$|App/Makefile$|App/project\.yml$)' \
  || git diff --cached --name-only 2>/dev/null | rg -q '^(Sources/|App/Atlas/ConversationModel\.swift$|App/Atlas/AtlasSession\.swift$|App/Makefile$|App/project\.yml$)'; then
  fail "forbidden Core/build paths touched"
fi

# Recent commit message smell (informational if no commits yet)
if git log -1 --pretty=%s 2>/dev/null | rg -qi 'collapse.*host|into host files'; then
  fail "last commit message smells like host-collapse"
fi

if [[ "$FAIL" -ne 0 ]]; then
  say "---"
  say "Fix process/ledger/files before committing. See docs/prompts/grok-24h-autonomous-deepening-v3.md"
  exit 1
fi

say "GUARD OK"
exit 0
