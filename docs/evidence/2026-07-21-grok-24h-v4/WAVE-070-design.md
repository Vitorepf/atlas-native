# WAVE-070 — autonomos-nightly-proposal-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-070-autonomos-nightly-proposal-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · residual Nightly organ)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `NightlyProposalController` + card spoken helpers own pending/muted/
  hidden paths **without pure Judgment** for the nightly proposal organ.
- Mute auto-pause vs manual mute are View/controller local; pack/Rhythm
  cannot reuse `nightly_face: pending|muted|muted_auto|hidden`.
- Residual after Autônomos bind (065) and rhythm lines: **proposta
  noturna** still dialect soup across Block/Card/Sheet.

## Patamar

| Antes | Depois |
|---|---|
| Bool mute + optional payload | Exclusive nightly face |
| Spoken card/mute local | Judgment spoken |
| No pack | Pack face + mute until + workspaces |

Δ = **soberania da proposta noturna** — pending ≠ mute ≠ silêncio.

---

## Arquitetura

### Princípios

- Casca only; pendingProposal + mutedUntil + autoPaused published.
- Honesty: no invent workspaces; mute silence = no card theater.
- One domain: nightly proposal organ (not full rhythm score).

### Fluxo

```
pending? + muted? + autoPaused?
  → NightlyProposalJudgment.face / spoken / pack
  → Block · Card · RhythmSheet peels
```

### Arquivos (≥5)

- `NightlyProposalJudgment.swift` (**new**)
- `NightlyProposalBlock.swift`
- `NightlyProposalCardBody.swift`
- optional RhythmSheet spoken mute
- CODEMAP · design · compress

### Densidade

Judgment 140–280.

### Fora de escopo

- Core scheduling  
- UNUserNotification rewrite  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD (≥5)

1. Exclusive face: pending · muted · muted_auto · hidden.
2. Card spoken accept/dismiss/mute from Judgment (or peel constants).
3. spokenMuteStatus path uses Judgment.
4. Block visibility token honesty preserved.
5. Pack face + absences.
6. accessibilityValue = productWord on card/block when visible.
7. Gates + CODEMAP.
8. DEVICE_PENDING.

## Anti-objetivos

- invent proposals  
- Core  
- micro-WAVE  

## Plano W2/W3

1. Judgment  
2. Wire Block/Card/Controller spoken  
3. CODEMAP · compress  

Estimativa: **6–8 files · 250–400 LOC**.

## Proof

1. pending payload → pending face.  
2. mute → muted face + silence.  
3. auto pause → muted_auto spoken.  
4. DEVICE_PENDING.

## Council

Empty QUEUE after idle ArtifactSheet. Nightly residual. §WAVE pass.

## §WAVE self-check

1–6 yes.

---

*End WAVE-070 design.*
