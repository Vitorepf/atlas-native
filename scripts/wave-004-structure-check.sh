#!/usr/bin/env bash
# WAVE-004 structural proof: RunSheet fuse + worker gap honesty (casca).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

n=$(find App/Atlas -name 'ArenaRunSheet*.swift' | wc -l | tr -d ' ')
echo "runsheet_files=$n"
if [[ "$n" -gt 8 ]]; then
  echo "FAIL: expected fused RunSheet ≤8 files, got $n"
  exit 1
fi

if ! rg -q 'worker de medição desligado no servidor — fila aguardando' \
  App/Atlas/ArenaRunSheet+Receipt.swift App/Atlas/ArenaRunSheet+Spoken.swift; then
  echo "FAIL: workerGapCopy missing from visual/spoken sources"
  exit 1
fi

# User-facing stale phrase must not remain (comments may mention it).
if rg -n 'ainda não implementado' App/Atlas/ArenaRunSheet*.swift | rg -v '^\s*//|never'; then
  echo "FAIL: stale 'ainda não implementado' still present"
  exit 1
fi

while read -r lines file; do
  [[ -z "${file:-}" ]] && continue
  base=$(basename "$file")
  if [[ "$base" == *View*.swift || "$base" == *Shell*.swift || "$base" == ArenaRunSheet.swift ]]; then
    if [[ "$lines" -gt 400 ]]; then
      echo "FAIL: god-file $file has $lines lines"
      exit 1
    fi
  fi
done < <(find App/Atlas -name 'ArenaRunSheet*.swift' -print0 | xargs -0 wc -l | sed '$d')

echo "WAVE-004 structure OK"
