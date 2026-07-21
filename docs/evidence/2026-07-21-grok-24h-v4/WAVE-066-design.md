# WAVE-066 — arena-now-phase-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-066-arena-now-phase-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · A runner-up residual)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- Arena Premium “agora” switches idle / queued / execution / terminal
  via **View-local configuration tuples** (`ArenaPremiumTerminalKind` +
  kickers) without pure **phase Judgment**.
- Pack/can_do hosts cannot reuse `arena_now_face: idle|queued|running|
  stopping|stopped|completed|failed`.
- Residual after live-control (050) · start (055) · suite (059): **now
  phase organ** still dialect soup across NowStates + route shell.
- Council runner-up after WAVE-065 multi-area.

## Patamar

| Antes | Depois |
|---|---|
| Terminal kind switch only | Exclusive now face for all phases |
| Kickers/titles local | Judgment title · subtitle · tone · symbol |
| No pack | Pack face + engine title honesty |
| Spoken state id only | Spoken face product words |

Δ = **soberania do agora da Arena** — idle ≠ fila ≠ terminal.

---

## Arquitetura

### Princípios

- Casca only; `ArenaModel` live/report/presentation already published.
- Honesty: never invent runs; terminal only from published stop/complete.
- One domain: arena now phase (not suite rank, not start receipt).

### Fluxo

```
model live presentation + terminal signals
  → ArenaNowJudgment.face / chrome / spoken / pack
  → ArenaPremiumNowStates peels
```

### Arquivos (≥5)

- `ArenaNowJudgment.swift` (**new**)
- `ArenaPremiumNowStates.swift`
- Optional Arena premium root/route if phase gate lives there
- CODEMAP
- design + compress

### Densidade

Judgment 150–320 · NowStates thinner.

### Fora de escopo

- Core arena API  
- Suite score  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD (≥5)

1. Exclusive face: idle · queued · running · stopping · stopped ·
   completed · failed.
2. Terminal chrome (title/subtitle/symbol/tone) from Judgment.
3. Idle/queued kickers spoken from Judgment where local today.
4. Pack face + absences.
5. accessibilityValue productWord on state chrome.
6. Gates + CODEMAP.
7. DEVICE_PENDING.

## Anti-objetivos

- invent live runs  
- fuse suite judgment  
- Core  
- micro-WAVE  

## Plano W2/W3

1. Judgment face + terminal chrome map.  
2. Wire NowStates.  
3. CODEMAP · compress.  

Estimativa: **5–7 files · 250–450 LOC**.

## Proof

1. Idle model → face idle.  
2. Queued runs → queued.  
3. Completed terminal → completed chrome.  
4. DEVICE_PENDING.

## Council

Empty QUEUE after 064/065. Arena now residual. §WAVE pass.

## §WAVE self-check

1–6 yes.

---

*End WAVE-066 design.*
