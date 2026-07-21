# WAVE-007 — autonomos-organism-truth

**Status:** design · proposed  
**Wave:** `WAVE-007-autonomos-organism-truth`  
**Owner:** casca only (Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v4 dual)  
**Δ patamar:** **high** (max no eixo Autônomos)  
**Rank:** 2  

---

## Problema

Autônomos v9 tem **casca avançada** (map shell, nightly, rhythm, self-construction
banner com gate de merge, pílula `AgenticAskDock`, pack presentation-only honesto).
Mas o organismo **mente na gramática**:

1. **Dual vestment (falha de produto).**  
   - Canônico: `AutonomosHubVestment` = `awaiting(n) | live | quiet` via
     `resolve(backlog, live, incidentPresent)` — decisões, run vivo, incidente.  
   - Hub face: `AutonomosHubView` usa **`LocalVestment` privado** = só
     `unit.paused ? .quiet : .live`. **`awaiting` nunca aparece no hub.**  
   - MapShell ask: vestment também colapsa para paused→quiet/live.  
   Resultado: o operador pode ter **decisões na inbox** e o hub grita “No escopo /
   Evoluindo” com outra voz — dois organismos no mesmo app.

2. **Dual hero copy.** Enum canônico: “1 decisão / Evoluindo / Em pausa”.  
   Local hub: “No escopo / Em pausa”. Kickers “Pede você / Vivo / Parado” vs
   textos locais. A identidade v9 dilui-se.

3. **Self-construction honesty parcial.** Banner só se
   `mergePerformed && !mergeHash.isEmpty` — bom. Mas rotas de decisão/incidente
   ainda são stub “quando create no Server existir” com tom que pode parecer
   frota real. Create local = UUID, `paused: true`, sem POST — pack admite;
   face precisa **uma** honestidade, não teatro de frota 24/7.

4. **Evolution nav** meta fixa “ainda sem provas” — ok se for a única voz;
   não inventar ledger.

Isto **não** é polish de caption. É o órgão **julgamento da frota soberana**
falando duas línguas.

---

## Patamar

| Antes | Depois |
|---|---|
| Hub ignora `AutonomosHubVestment.resolve` | Hub + ask + chrome usam **só** o enum canônico |
| `awaiting` morto na face | Decisões reais → “Pede você / N decisões” |
| LocalVestment + hero dual | Delete LocalVestment; uma gramática v9 |
| Stubs com tom de frota | Empty honesto único; zero contagens inventadas |

Δ = **verdade do organismo** (julgamento soberano do operador sobre a frota).
Sem create server (Core), a casca ainda pode unificar vestment nos sinais
**já carregados** (backlog/live/incident/local pause).

---

## Arquitetura

### Princípios

- **Uma vestimenta.** `AutonomosHubVestment` é a **única** fonte de kicker/hero/
  nav/ask invite branch.
- **Resolve com o que existe.**  
  ```
  vestment = AutonomosHubVestment.resolve(
    backlog: model.backlog,   // may be nil
    live: model.live,
    incidentPresent: …
  )
  // Local unit.paused: se paused e resolve==.live sem live real → prefer .quiet
  // Documentar regra: pause local vence live inventado; awaiting vence quiet.
  ```
  Regra de precedência proposta (casca):
  1. Se há decisões (`awaiting`) → awaiting (mesmo se paused? **Não:** paused
     local sem server decisions → quiet; se backlog real com decision → awaiting).
  2. Se `unit.paused` e não há live/incident server → quiet.
  3. Caso contrário `resolve(...)`.
- **Self-construction:** banner/sheet **somente** merge proved; zero “melhorou”.
- **Stubs de decisão/incidente:** um empty editorial honesto (“ainda no escopo
  local / create no servidor não liga”) — **sem** badge numérico inventado.
- **Casca only.** Create POST, M01 merge_performed no server = §5; não fingir.
- **Hosts ≤400.** `AutonomosMapShell` hoje ~224; não monolitizar.

### Fluxo (após onda)

```
model.load → backlog/live/delivered/…
           → vestment = resolve + pause rule
           → Hub hero/kicker/nav = vestment.*
           → Ask invite = AutonomosAskContext.invite(..., vestment:)
           → catalog face nightly/rhythm unchanged
           → selfConstruction only if merge proved
```

### Fora de escopo

- POST create Autônomo no server (Core/Codex).
- M01 heal merge pipeline.
- Redesign map chrome craft / type identity (já leap8).
- Failure dialect unify (WAVE-008).
- Nova área / tab / “Missions”.
- Collapse MapShell into god-file.

---

## Arquivos (W2)

| Path | Mudança |
|---|---|
| `AutonomosHubView.swift` | **Delete `LocalVestment`**; consumir `AutonomosHubVestment` |
| `AutonomosMapShell.swift` | `vestmentForAsk` = mesma resolve+pause rule; hero paths se houver |
| `AutonomosAskContext.swift` | invites alinhados aos 3 cases canônicos (já parcialmente) |
| `AutonomosHubVestment.swift` | helper `resolve(…, unitPaused:)` se a regra precisar de um lugar |
| `AutonomosMapChrome.swift` / nav lines | kicker/hero de vestment, não strings soltas |
| Decision/incident stub faces | empty honesto único; zero fake counts |
| SelfConstruction* consumers | só gate merge; copy sem overclaim |
| A11y hub/catalog | spoken = vestment; IDs estáveis |

### W3

| Alvo | Estimativa |
|---|---|
| Delete LocalVestment + dual hero | −40…−80 |
| Fuse stub empties / duplicate kickers | −40…−120 |
| Residual a11y peels só se tocados | −0…−50 |
| **Meta** | **−80…−250** honest (DoD-first; Δ patamar > ΔLOC) |

Report em `WAVE-007-compress.md`.

---

## DoD (≥5 — observável)

1. **Hub usa apenas `AutonomosHubVestment`** — zero `LocalVestment` / enum
   privado paralelo (`rg LocalVestment` = 0).
2. **`resolve` wired** a backlog/live/incident **reais** do model quando
   carregados; absences publicadas (quiet + copy), nunca inbox inventada.
3. **Ask invite vestment ≡ hub vestment** na mesma ocasião (mesmo unit + model).
4. **Self-construction** banner/sheet só com `mergePerformed && hash`; zero
   copy de cura sem prova.
5. **Decision/incident routes:** um padrão empty honesto; sem contagens fake.
6. **A11yIDs** hub/catalog/ask estáveis; spoken reflete awaiting/live/quiet.
7. Gates guard + AtlasCoreChecks + `make build`; nenhum host >400.

---

## Anti-objetivos

- “Honesty residual” de caption/a11y peels sem unificar vestment (**micro**).
- Fingir frota server-side create/live para unit local.
- Inventar `awaiting` sem backlog decision flags.
- Redesign visual do mapa v9 sem mudança de verdade.
- Tocar Core / AutonomosModel lógica de load (só presentation se preciso).
- Failure empty canon (WAVE-008).

---

## Plano W3

1. DoD verde com vestment único.
2. Delete dead LocalVestment + strings órfãs.
3. Fundir peels de hub header se dual copy residual.
4. Numstat honesto; residual listado.

---

## Critérios §B

| Critério | Pass? |
|---|---|
| Muda patamar | **SIM** — organismo deixa de mentir |
| DoD ≥5 / multi-surface | Hub + MapShell + Ask + stubs |
| Casca-desbloqueada | **SIM** (create server fora) |
| Design ≥80 + arch + anti + W3 | **SIM** |
| Anti-micro | **SIM** — dual grammar é estrutural |

---

## Reviewer (self · 0 critical)

| Issue | Sev | Resolution |
|---|---|---|
| Pause local vs awaiting conflict | critical if ambiguous | Precedence table no design + helper único |
| resolve com backlog nil vira quiet forever | major | quiet + absence copy; não inventar |
| Overclaim “Evoluindo” sem live | major | resolve already gates on live?.isRunning |
| Scope creep failure dialect | minor | WAVE-008 |

**Critical open:** 0.

---

## §5 (anotar no design; não bloquear casca)

- [ABERTO · Autônomos] POST create no servidor + persistência de unit operador.  
- [ABERTO · M01] `merge_performed` / delivered self-construction no app path.  
Casca **não** espera estes para unificar vestment nos sinais já loadados.

---

## Approval

- [x] §B pass  
- [x] Sections complete  
- [ ] `approved` — Implementer auto-approve rank≤2 OK  

## Explores

- explore Island/Autonomos/Home: top #1 Autônomos  
- v3 LEDGER candidate WAVE-007  
- live `AutonomosHubView` LocalVestment vs `AutonomosHubVestment`  
