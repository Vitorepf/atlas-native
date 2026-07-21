# WAVE-077 — autonomos-rhythm-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-077-autonomos-rhythm-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · empty queue · residual after WAVE-070 nightly)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `AutonomosRhythmCopy` owns learning vs learned line/paragraphs and
  pause overlay **without pure Judgment** for the rhythm organ.
- WAVE-070 closed nightly proposal face; residual **day-rhythm learning
  organ** (sampleDays · dayEnd · pause) still dialect soup on Sheet/Line.
- Pack cannot reuse `rhythm_face: learning|learned|paused`.

## Patamar

| Antes | Depois |
|---|---|
| sampleDays < 4 soup | Exclusive rhythm face |
| Copy local | Judgment line/spoken/paragraph |
| No pack | Pack face + sampleDays + dayEnd |

Δ = **soberania do ritmo aprendido** — ainda aprendendo ≠ aprendido ≠ pausa.

---

## Arquitetura

### Princípios

- Casca only; `AtlasDayRhythm.Windows` published on-device only.
- Honesty: sampleDays < 4 never claims “learned”; no invent hours.
- One domain: autonomos day rhythm (not nightly proposal bind).

### Fluxo

```
windows.sampleDays + dayEnd? + paused?
  → AutonomosRhythmJudgment.face / line / spoken / pack
  → RhythmCopy peels · LearningLine · Sheet
```

### Arquivos (≥5)

- `AutonomosRhythmJudgment.swift` (**new**)
- `AutonomosRhythmSheet.swift` (Copy peels)
- `AutonomosRhythmLearningLine.swift`
- CODEMAP · design · compress

### Densidade

Judgment 150–300.

### Fora de escopo

- Core rhythm  
- Nightly proposal rewrite  
- Micro tipografia  

### §5

`nenhum`.

---

## DoD (≥5)

1. Face: learning · learned · paused (pause overlays learned/learning).
2. line + spokenLine from Judgment.
3. learnedParagraph / whatHappens from Judgment.
4. Pack face + sampleDays + dayEnd hour?
5. accessibilityValue productWord on LearningLine.
6. Gates + CODEMAP.
7. DEVICE_PENDING.

## Anti-objetivos

- invent windows  
- fuse NightlyProposalJudgment file  
- Core  
- micro-WAVE  

## Plano W2/W3

1. Judgment  
2. Wire Copy + LearningLine  
3. CODEMAP · compress  

Estimativa: **5–6 files · 220–360 LOC**.

## Proof

1. sampleDays 2 → learning.  
2. sampleDays 4+ → learned.  
3. paused true → paused spoken suffix.  
4. DEVICE_PENDING.

## Council

Empty QUEUE. Rhythm residual after nightly. §WAVE pass.

## §WAVE self-check

1–6 yes.

---

*End WAVE-077 design.*
