# Onda 0 — Profundidade Total (2026-07-17)

## M01 · Ciclo V3 com merge → delivered — PARCIAL (último passo real)

**Provado antes / nesta era:**
- Worker `software_company_loop` (dry_run RUNNING→DONE)
- Healer R2 `atlas:native:constitution-heal` (canário healed, `merge_performed=false`)
- Lease livre em `atlas-native` (`lock.held=false`)

**Probe 2026-07-17:**
```
GET …/loop/atlas-native/done?focus=dev_forge
→ delivered_total=0, ledger_record_count_total=59, returned=0
```

**Bloqueio real (não simulado):** heal mecânico R2 **não** escreve ledger AP-790 com
`outcome=merged` + `merge_performed=true` + `merge_hash`. SCL execute via AP-786
é ferramenta errada para dead_symbol. Sem bridge heal→commit→merge→ledger,
`model.delivered` permanece vazio por contrato.

**Próximo (dono: Codex/server):** bridge governado pós-heal OU contrato
heal-receipt separado de `/done` — ver OBRA §5.

**2026-07-17 cloud agent:** `atlas-server` **ausente** neste workspace Linux
→ A1.1b/c **BLOCKED(server)**. Casca nativa já só mostra
“O ATLAS MELHOROU…” quando `deliveredTotal > 0` (fail-closed).

## M02 · DEVICE_PROVEN prints — PENDENTE OPERADOR

Roteiro (iPhone desbloqueado, `passcodeRequired=false`):
1. `cd App && make device`
2. Fotos: U1 strip, U2 composer 3-estados, U4 erro editorial, U5 AXXXL,
   U6 ícone home, U8 timeline viva, U9 notificação lock, U10 Live Activity
3. Salvar em `docs/evidence/<data>-device-proven/01..08.png`
4. Marcar U1–U10 DEVICE_PROVEN na fila §4

## M03 · Baselines Instruments — PENDENTE OPERADOR

No iPhone Debug + Instruments:
- App Launch → cold launch (alvo <400ms)
- Animation Hitches → scroll streaming 40k (alvo 0 @120Hz)
- Allocations → grafo 200 nós; upload 20MB (<60MB incrementais)
Salvar traces em `docs/evidence/perf-baseline/`.

## M04 · APNs cofre — PENDENTE OPERADOR

Apple Developer: Push Notifications `com.vitor.atlas.native`.
Cofre server: `ATLAS_LIVE_ACTIVITIES_APNS_KEY_ID`, `_TEAM_ID`, `_PRIVATE_KEY`,
`ATLAS_LIVE_ACTIVITIES_ENABLED=true`. Prova: LA atualizada com app morto.

## M05 · Verticais device — PENDENTE OPERADOR

Repetir V1/V2/V4/V5 no físico (V3=M01). Evidence:
`docs/evidence/<data>-verticais-device/`.

## M06 · Live-probe integral — DONE

`ATLAS_LIVE=1 ATLAS_TOKEN=… swift run AtlasCoreChecks` exit 0.
Log: `m06-live-probe.log` (create→SSE→done, upload 3.2MB sha, C4 long message).
