# WAVE-032 — workspace-live-thread-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-032-workspace-live-thread-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · idle-empty → self-WAVE A-bar)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen — não hand-rank)

---

## Problema

- WAVE-029 fechou **pack mid-thread** (ConversationOccasionPack).  
  WAVE-023/LiveNow fecharam **hub VIVO AGORA** com judgment order.  
  Residual **Workspace** (e Search list): lista de threads ainda é
  **recência crua** / ordem do catálogo — sem **live-first** por `threadId`.
- `ThreadRow` marca vivo via `TurnPresence.shared.runningTitles.contains(title)`
  — **match por título**, colide entre conversas com o mesmo título e
  **erra** quando o título diverge do phase title.
- Operador abre Workspace com run vivo na 8ª linha e **julga o catálogo
  quiet** — mentira de atenção. LiveNow eleva; Workspace não.
- Pack `WorkspaceAskContext` lista hub_live global com honesty, mas **não**
  eleva threads **deste** workspace com live matching threadId.
- Council WAVE-030/031 listou explicitamente este residual como runner-up
  high/max **workspace** — casca-only, zero Core.

## Patamar

| Antes | Depois |
|---|---|
| Workspace list = wire/recency only | **Live-first** por threadId (TurnPresence + remote) |
| Running badge by title string | Prefer **threadId** match; title fallback only |
| Search list parallel dialect | **Same** judgment helper (parity) |
| Pack workspace sem live slice | Pack: live_in_workspace · subjects top live |
| Operador caça run no scroll | Em ≤5s vê o que está **vivo neste workspace** |

Δ = soberania de **atenção no catálogo de trabalho** — o workspace deixa de
fingir quiet enquanto o hub grita VIVO AGORA.

---

## Arquitetura (croqui)

### Princípios

- **Casca only.** `TurnPresence.shared.liveSessions`, `session.remoteLiveSessions`,
  `AtlasAiThread.id` / `title` já publicados.
- **Honesty:** zero inventar live; unscanned/empty → wire order.
- **threadId > title** for running signal; title fallback only if threadId nil.
- **Silence clean:** no live chrome when no match.
- **One domain:** Workspace/Search catalog judgment — not Autônomos/Arena.
- Pack 020 grammar: facts + absences + can_do readChat.

### Fluxo

```
threads (workspace | free | search filter)
  → WorkspaceThreadJudgment.rank(threads, live: local+remote)
      live-by-threadId first → title-fallback running → rest stable
  → ThreadRow.isRunning prefers threadId set
  → pack WorkspaceAskContext.liveSubjects(workspaceKey)
```

### Tipos / módulos

| Nome | Papel |
|---|---|
| `WorkspaceThreadJudgment` | pure rank + running set + pack subjects |
| `ThreadRow` | isRunning honesty (threadId first) |
| `WorkspaceSurface` / Search | consume rank |
| `WorkspaceAskContext` | live facts for this workspace |

### Arquivos prováveis

- `WorkspaceThreadJudgment.swift` (**new**)
- `WorkspaceSurface.swift` — rank threads
- `SearchSurface.swift` — same rank on results
- `RootChrome.swift` — ThreadRow running signal
- `WorkspaceAskContext.swift` — pack live slice
- `CODEMAP.md` — onde julga workspace list

### Densidade

- Judgment 200–800  
- View shells thin  
- Surface ≤1500  
- Fail >2000 / multi-domínio

### Fora de escopo

- Core new thread DTO  
- App Group Continuity  
- Autônomos/Arena  
- Re-chrome pill  
- Nova área  
- Metal / graph

### §5 Core

`nenhum`. Tudo presentation de session + TurnPresence.

---

## DoD produto (≥5)

- [ ] Workspace threads: **live-first** when TurnPresence/remote match by
      threadId (stable secondary order).
- [ ] ThreadRow running: **threadId set** preferred; title fallback only.
- [ ] Search results use **same** judgment rank helper (parity).
- [ ] Quiet workspace: no fake live chrome; order honest wire/recency.
- [ ] Workspace pack facts include live-in-workspace count + top subjects;
      absences when none.
- [ ] Spoken a11y still reports live when row is live.
- [ ] Gates + CODEMAP "workspace live judgment".

## Anti-objetivos

- micro tipografia / opacity ladder  
- invent live without signal  
- fuse multi-domínio Home+Autônomos monólito  
- Core edits  
- micro-WAVE &lt;5 files / &lt;30 min fingindo GOD  
- App Group data

## Plano W3 GOD

1. Extract `WorkspaceThreadJudgment` pure.  
2. Wire Workspace + Search rank.  
3. Fix ThreadRow running identity.  
4. Pack live slice.  
5. MARK se densificar.  
6. CODEMAP.  
7. Estimativa: **~5–8 arquivos · ~250–500 LOC** estrutural — ≥5 files, DoD≥5.

## Proof / device

1. Workspace com 1 thread live → top of list + badge.  
2. Two same-title threads: only matching threadId shows live.  
3. Search parity.  
4. Empty live → no reordering noise.  
5. DEVICE_PENDING se passcode.

## Council

**Home/Workspace residual #1** after 029 pack = this catalog judgment.  
**Código** residual closed by 028. **Autônomos** by 026/030. **Conversa**
by 027/029/031. Δ **high** — fecha o último furo de **atenção no
diretório de trabalho** sem Core.

---

## §WAVE self-check (B)

1. Muda patamar: sim (workspace attention)  
2. DoD ≥5: sim  
3. Casca-unblocked: sim  
4. Design ≥120 linhas: sim  
5. Não cabe em &lt;30 min / &lt;5 files: ~6 files + judgment  
6. Densidade agent-optimal no plano: sim  
