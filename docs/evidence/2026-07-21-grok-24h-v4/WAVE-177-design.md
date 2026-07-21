# WAVE-177 — autonomos-rhythm-pack-async-wire

**Status:** design · proposed · high
**Wave:** WAVE-177-autonomos-rhythm-pack-async-wire
**Owner:** casca only · residual full-bar
**Date:** 2026-07-21
**Created by:** implementer residual after 174–176
**Δ patamar:** **high**

## Problema
`AutonomosRhythmJudgment.packFacts` is the **last hollow** packFacts
(zero external caller). Catalog AskContext leaves honest absence
“ritmo: janelas async — face RhythmLearningLine carrega sample; pack não
inventa windows”. That was correct **before** Search/timeline closed —
now the host path is clear: `turnFacts` is **async**, and
`AtlasSession.rhythm.windows(minimumDays:)` is the same load the face
already uses. Pack can await sample without inventing windows.

## Patamar
| Antes | Depois |
|---|---|
| Rhythm packFacts dead | Wired on Autônomos catalog pack |
| Absence always async | Facts when windows load; absence only on fail |
| Nightly without day rhythm | Rhythm face + sample_days + day_end honesty |

Δ = last Judgment pack sovereignty + Autônomos catalog honesty.

## Arquitetura
Casca only · zero Core · await in turnFacts closure only.

### Fluxo
```
AutonomosMapShellAsk.turnFacts (async)
  → windows = await AtlasSession.rhythm.windows(minimumDays: 4)
  → AutonomosAskContext.facts(..., rhythmWindows: windows)
  → appendVetoNightlyCanDoOrgans wires AutonomosRhythmJudgment.packFacts
  → remove invent-free permanent absence when windows present
```

### Arquivos (≥5)
1. AutonomosAskContext.swift — optional rhythmWindows param
2. AutonomosAskContextOrgansVeto.swift — wire packFacts
3. AutonomosMapShellAsk.swift — await windows
4. AutonomosRhythmJudgment.swift — (no invent; already pure)
5. CODEMAP + design + compress + DONE + LEDGER

### Densidade
wire only · Judgment untouched size

### Fora de escopo
- Core rhythm storage
- Search rework (176 closed)
- Density peels
- Invent sample_days

### §5
nenhum

## DoD produto (≥5)
- [ ] AutonomosRhythmJudgment.packFacts external caller (rg)
- [ ] Catalog pack includes rhythm_face when windows load
- [ ] Absence only when windows nil / destination not catalog
- [ ] paused/muted still honesty via face
- [ ] Gates green
- [ ] CODEMAP + DEVICE_PENDING

## Anti-objetivos
micro-WAVE · invent windows · tipografia · Core

## Plano W3
1. Param rhythmWindows 2. Wire organ 3. Await host 4. Gates 5. CODEMAP DONE

## Proof
1. Fresh install sampleDays < 4 → learning face in pack
2. Learned dayEnd → rhythm_day_end fact
3. Muted → paused face
4. DEVICE_PENDING

## Council
Last true hollow after 174–176. Full-bar pack wire class.

### Why full-bar
≥5 files · ≥120 design · DoD≥5 · product honesty · not idle MARK

### Rejection
sync invent sample · density-only

### Related
WAVE-159 nightly · WAVE-077 rhythm face · WAVE-176 search host pattern

### Sequence after
A fill · strip/card unify if A designs

### Acceptance
Build green · hollow count 0 for packFacts Judgments

### W2/W3
Wire · CODEMAP · DONE · compress · regen · LEDGER

---

## Appendix — pack shape

```
facts:
- rhythm_face: learning|learned|paused
- rhythm_sample_days: N
- rhythm_day_end: HH:MM   # when known
absences:
- ritmo ainda em amostragem (< 4 dias)   # learning
```

## Appendix — non-goals

Do not block ask sheet on slow disk; windows() is local actor file.
Do not publish day rhythm on unit destination packs (catalog only).

## Appendix — risk

await in turnFacts adds latency once per ask open — acceptable (same as face .task).

## Appendix — test matrix

| case | expect |
|---|---|
| sample 0 | learning + absence sampling |
| sample 4+ dayEnd | learned + day_end |
| muted | paused |
| destination != catalog | skip rhythm organ |

## Appendix — commit

`feat(ui): WAVE-177 autonomos rhythm pack async wire`

## Appendix — god

No rename. packFacts sovereignty.

## Appendix — dual A

A may design strip/card next; B does not invent micro.

## Appendix — density

AskContext param + organ branch · MapShell await · <80 LOC net

## Appendix — a11y

Unchanged face path.

## Appendix — idle

Not IDLE — product pack wire residual full-bar after A 175–176 drain.
