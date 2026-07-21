# WAVE-178 — composer-send-face-pack-wire

**Status:** design · proposed · high
**Wave:** WAVE-178-composer-send-face-pack-wire
**Owner:** casca only · residual full-bar
**Date:** 2026-07-21
**Created by:** implementer residual (A runner-up after 175–176)
**Δ patamar:** **high**

## Problema
`ComposerSendJudgment` owns exclusive send face (empty/ready/blocked/
queueOnly/executing) on the gold CTA — **zero packFacts**. Mid-thread
pack has draft strip · effort · queue · toolbar mode but **not** send
readiness. Agent cannot know if CTA is blocked by failed upload vs
executing vs empty without inventing. A council runner-up after Search
and review assinatura.

## Patamar
| Antes | Depois |
|---|---|
| Send face UI-only | packFacts send_face · allows_send |
| blocked_failed silent | absence + fact honesty |
| queueOnly vs ready opaque | productWord in pack |
| ≤5s “posso mandar?” pack mute | Pack ≡ gold CTA law |

Δ = composer send sovereignty mid-thread.

## Arquitetura
Casca only · PublishedSlice + draftText/isSending · Organs wire.

### Fluxo
```
ConversationSurface rebind
  → PublishedSlice.draftText / isSending / drafts / presenceBubble
  → ComposerSendJudgment.packFacts(...)
  → OccasionPackOrgans next to draft/effort
```

### Arquivos (≥5)
1. ComposerSendJudgment.swift — packFacts
2. ConversationOccasionPack.swift — PublishedSlice fields
3. ConversationSurface.swift — bind model fields
4. ConversationOccasionPackOrgans.swift — wire
5. CODEMAP + design + compress + DONE + LEDGER

### Densidade
Judgment +30 · slice +2 fields

### Fora de escopo
Core · invent send · tipografia · density peels · strip/card dual

### §5
nenhum

## DoD produto (≥5)
- [ ] packFacts send_face productWord
- [ ] allows_send honesty
- [ ] blocked_failed / uploading absences
- [ ] executing / queueOnly when live
- [ ] Gates + CODEMAP
- [ ] DEVICE_PENDING

## Anti-objetivos
micro rename · invent text · Core send

## Plano W3
1. packFacts 2. slice fields 3. surface bind 4. organs wire 5. CODEMAP DONE

## Proof
1. empty draft → empty face pack
2. text ready → ready + allows yes
3. failed draft → blocked_failed
4. live bubble + text → queueOnly
5. DEVICE_PENDING

## Council
A runner-up composer-send-face-pack. Pack hollows 0 on existing packFacts;
this **adds** missing organ pack for live face.

### Why full-bar
≥5 files · ≥120 design · DoD≥5 · product CTA honesty

### Rejection
MARK-only · opacity

### Related
WAVE-164 draft · WAVE-046 send face · WAVE-095 can_do

### Sequence after
A strip/card unify if designed

### Acceptance
Build green · DEVICE_PENDING

### W2/W3
Wire · CODEMAP · DONE · compress · regen · LEDGER

---

## Appendix — pack shape

```
facts:
- send_face: ready|empty|blocked_failed|…
- send_allows: yes|no
absences:
- composer sem payload (vazio)
- anexo falhou — remova ou reconecte
```

## Appendix — non-goals
Do not change CTA chrome. Do not NL-authorize send.

## Appendix — risk
draftText snapshot at rebind — same as drafts already published.

## Appendix — test matrix

| case | face |
|---|---|
| empty | empty |
| text | ready |
| fail attach | blocked_failed |
| live+text | queueOnly |

## Appendix — commit
`feat(ui): WAVE-178 composer send face pack wire`

## Appendix — god
One law face ≡ pack productWord.

## Appendix — dual A
Strip/card dual deferred to A design.

## Appendix — density
ComposerSend stays <200.

## Appendix — a11y
spoken already Judgment.

## Appendix — idle
Not idle MARK — product pack organ.
