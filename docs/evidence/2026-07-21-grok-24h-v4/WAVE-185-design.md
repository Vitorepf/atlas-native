# WAVE-185 — conversation-thread-shell-and-workspace-shell-pack

**Status:** design · proposed · high
**Wave:** WAVE-185-conversation-thread-shell-and-workspace-shell-pack
**Owner:** casca only · residual full-bar
**Date:** 2026-07-21
**Created by:** implementer residual after 184
**Δ patamar:** **high**

## Problema
1. **ConversationOccasionPack** host still hand-rolls thread shell
   (thread_id · title · workspace_key/name/path · catalog absences) while
   every organ is Judgment-packed — last mid-thread shell soup.
2. **WorkspaceAskContext** hand-rolls shell (workspace_key · conversas count ·
   caminho · hub live lines) while screen/empty/fail/live-scoped are packed.

## Patamar
| Antes | Depois |
|---|---|
| mid-thread shell hand-roll | ConversationThreadShellJudgment.packFacts |
| workspace shell hand-roll | WorkspaceThreadJudgment.packShellFacts |
| dual host dialects | one law packFacts for shell identity |

Δ = conversation + workspace shell pack sovereignty.

## Arquitetura
Casca only · session catalog published · never invent workspace path.

### Fluxo
```
ConversationOccasionPack.facts
  → ConversationThreadShellJudgment.packFacts(...)
  → live/empty/organs unchanged

WorkspaceAskContext.facts
  → WorkspaceThreadJudgment.packShellFacts(...)
  → hub live via LiveNow or thin host lines
  → liveInWorkspaceFacts + screen/empty/fail
```

### Arquivos (≥5)
1. ConversationThreadShellJudgment.swift (**new**)
2. ConversationOccasionPack.swift — wire
3. WorkspaceThreadJudgment.swift — packShellFacts
4. WorkspaceAskContext.swift — wire
5. CODEMAP + design + compress + DONE + LEDGER

### Densidade
new Judgment 80–120 · hosts ↓LOC

### Fora de escopo
Core · invent paths · density peels · tipografia · ConversationModel logic

### §5
nenhum

## DoD produto (≥5)
- [ ] ConversationThreadShellJudgment.packFacts mid-thread
- [ ] workspace binding absences honest
- [ ] Workspace packShellFacts external caller
- [ ] hosts lose hand-roll shell fields
- [ ] Gates + CODEMAP
- [ ] DEVICE_PENDING

## Anti-objetivos
invent workspace · micro rename · Core

## Plano W3
1. Thread shell Judgment 2. Wire OccasionPack 3. Workspace shell pack 4. Wire Ask 5. gates CODEMAP DONE

## Proof
1. open thread with workspace → key+name
2. thread not in catalog → absence
3. workspace path missing → absence
4. DEVICE_PENDING

## Council
Last hand-roll shells on conversation + workspace Ask after 174–184 organ packs.

### Why full-bar
≥5 files · ≥120 design · DoD≥5

### Rejection
thread shell alone without workspace · MARK-only

### Related
WAVE-029 occasion · WAVE-032 workspace live · WAVE-184 home catalog

### Sequence after
await A

### Acceptance
Build green

### W2/W3
Wire · CODEMAP · DONE · compress · regen · LEDGER

---

## Appendix — thread shell pack

```
facts:
- thread_id: …
- thread_title: …
- workspace_key / workspace_name / workspace_path
absences:
- workspace da thread não publicado
- thread ainda não listada no catálogo
```

## Appendix — workspace shell

```
facts:
- workspace_key
- workspace_thread_count
- workspace_path (when listed)
absences:
- caminho completo não listado
- ainda não há conversas
```

## Appendix — non-goals
Re-rank threads · invent live stop

## Appendix — risk
subject title empty → prefix(8) honesty

## Appendix — test matrix

| case | expect |
|---|---|
| title empty | conversa + prefix |
| no ws key | path from thread or absence |
| empty workspace | thread count 0 |

## Appendix — commit
`feat(ui): WAVE-185 conversation and workspace shell pack`

## Appendix — god
shell identity one law

## Appendix — dual A
—

## Appendix — density
hosts thinner

## Appendix — a11y
unchanged

## Appendix — idle
product pack not MARK
