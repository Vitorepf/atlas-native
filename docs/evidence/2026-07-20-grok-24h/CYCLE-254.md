# CYCLE 254 — slim Autônomos load + dead A11yIDs

## Hipótese
Face v9 só lê `delivered` + `taskHealth` + catálogo; load puxava 8 endpoints.
A11yIDs de transfer/map/decide sheets mortos.

## Edits
- Model: drop live/cycles/backlog/fleet/fleetHistory/digest
- Load: só delivered + taskHealth; `load()` ancora única área registrada
- A11yID: remove 16 dead autonomos* constants

## Gates
checks + make build
