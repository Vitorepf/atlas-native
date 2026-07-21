# WAVE-008 — ops-failure-empty-canon

**Status:** design · proposed  
**Wave:** `WAVE-008-ops-failure-empty-canon`  
**Owner:** casca only (Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v4 dual)  
**Δ patamar:** **high** (transversal honesty)  
**Rank:** 3  

---

## Problema

O operador encontra **quatro dialetos** de “ops quebrado”:

| Superfície | Tipo atual | Tom |
|---|---|---|
| Home / Search / Conversation load | `AtlasNetworkFailureEmpty` + `AtlasFailureCopy` | Editorial shared |
| Código | `AtlasCodeLoadFailureEmpty` (~7 peels) | Dialeto próprio |
| Arena Premium | `ArenaPremiumLoadFailureView` | Glyph+kicker Arena + domain-unavailable |
| Autônomos | `AutonomosFleetFailureEmpty` (~4 peels) | VStack genérico |

A lei GOD (A04 / anti-inchaço): **um chrome de falha**, segundo consumidor real —
não quatro famílias. WAVE-003 já cravou **fail ≠ empty** na conversa. Ops Code/
Arena/Autônomos ainda **não** compartilham a máquina.

Isto não é unificar opacity. É o operador **reconhecer falha** em qualquer
face ops e saber o que fazer (retry / token / domínio ausente) com a **mesma
gramática visual e spoken**, sem transformar load-fail em empty idle.

---

## Patamar

| Antes | Depois |
|---|---|
| 4 famílias de failure empty | **Uma** primitiva ops-failure com slots |
| Arena domain-absent misturável mentalmente com offline | Domain-absent = **tom distinto**, mesma máquina |
| Code/Autônomos peels de failure | Consumers finos; copy/glyph por slot |
| Conversation/Home já bons | **Não regridem** |

Δ = honesty transversal + craft único + compressão real de torres de failure.

---

## Arquitetura

### Primitiva (casca)

```swift
// Nome ilustrativo — Implementer escolhe se estende AtlasNetworkFailureEmpty
// ou extrai OpsFailureEmpty compartilhado.

OpsFailureSurface / AtlasOpsFailureEmpty
  kind: network(AtlasNetworkFailureKind?) | domainUnavailable | message(String)
  surfaceID: A11y (por host)
  kicker: String?          // opcional editorial
  headline: String         // serif
  footnote: String?        // italic secondary
  symbol: String           // SF Symbol
  tone: neutral | attention
  onRetry: (() -> Void)?
```

### Regras

1. **Fail ≠ empty.** Nunca renderizar failure como `EmptyConversation` /
   empty catalog “sem itens”.
2. **Domain-unavailable** (Arena não publicada, etc.) ≠ offline. Mesma máquina;
   kicker/symbol/tone diferentes; copy proíbe inventar índices/scores.
3. **Copy source of truth:** preferir `AtlasFailureCopy` para kinds de rede;
   hosts passam override só quando o domínio exige (Arena unpublished).
4. **A11y IDs por superfície** preservados (`codeLoadFailure`, `arenaPremiumState
   ("failed-load")`, `autonomosLoadFailure`, home failure) — alias se preciso.
5. **Home/Search/Conversation** já em `AtlasNetworkFailureEmpty` — migrar **para
   a primitiva unificada** ou tornar Code/Arena/Autônomos consumers dela (preferir
   **estender o shared existente** a ser a primitiva, não criar terceira família).

### Estratégia de unificação (preferida)

```
AtlasNetworkFailureEmpty  (hoje Home/Search/Conversation)
  + slots: kicker, domainUnavailable mode, symbol override, surface a11y
  → Code / Arena / Autônomos passam a chamar o mesmo tipo
  → deletar AtlasCodeLoadFailure* tower peels
  → enxugar ArenaPremiumLoadFailureView → thin wrapper
  → enxugar AutonomosFleetFailureEmpty → thin wrapper ou delete
```

### Fora de escopo

- Inventar kinds Core novos.
- Offline detection protocol.
- Empty **idle** redesign (Conversation empty, catalog empty sem erro).
- Continuity widget “abra o Atlas” install empty (outro mundo; App Group).
- Token ladder “compress”.

---

## Arquivos (W2)

| Path | Mudança |
|---|---|
| `WorkspaceEmptyStates.swift` (+ Chrome/Retry/Failure*) | Expandir primitiva shared; slots |
| `AtlasFailureCopy*` | Manter como source de headline/hint rede; opcional domain |
| `AtlasCodeLoadFailure*.swift` | Substituir por shared; delete peels mortos |
| `ArenaPremiumLoadFailureView.swift` | Thin host → shared + domain mode |
| `AutonomosView+Failure*.swift` | Thin host → shared |
| Hosts que montam failure | Code/Arena/Autônomos/Home/Search — call sites |
| A11yID* | Preservar IDs; documentar se alias |

### W3

| Alvo | Estimativa |
|---|---|
| Delete Code failure peels (~7) | −80…−120 |
| Fuse Autônomos failure peels | −40…−80 |
| Collapse WorkspaceEmptyStates micro-peels tocados | −50…−200 |
| Arena thin | −10…−20 líquido se wrapper |
| **Meta** | **−150…−400** + coherence Δ |

`WAVE-008-compress.md` com numstat.

---

## DoD (≥5 — observável)

1. **Uma primitiva** de ops-failure consumida por **Code + Arena + Autônomos +
   Home/Search/Conversation** (slots only).
2. **Domain-unavailable** (Arena) permanece distinto de offline/timeout na
   copy e symbol; **mesma** máquina de layout/retry.
3. **Fail ≠ empty** em todas as faces tocadas (nenhuma vira lista vazia silenciosa).
4. **Zero métricas inventadas** em failure (sem scores 0, sem “0 sem retorno”
   como mascarada de erro de load).
5. **A11y IDs** por superfície estáveis (XCUITest / probes).
6. `rg AtlasCodeLoadFailureEmpty` pós-onda: só typealias/compat ou 0; peels
   órfãos deletados.
7. Gates guard + checks + build; hosts ≤400.

---

## Anti-objetivos

- Só trocar fontes/opacity entre dialetos.
- Forçar copy idêntica onde domínio exige voz (Arena unpublished).
- Unificar empty **idle** com failure.
- God-file de failure 400+.
- Core edits.

---

## Plano W3

1. Shared slots verdes em 3+ hosts.
2. Delete towers Code/Autônomos.
3. Fuse peels WorkspaceEmptyStates se o wave tocá-los (não chase global).
4. Numstat + residual (ex.: ArtifactSheet empty permanece fora se não for load-fail).

---

## Critérios §B

| Critério | Pass? |
|---|---|
| Muda patamar | **SIM** — honesty transversal |
| ≥3 superfícies | Code + Arena + Autônomos (+ Home) |
| Casca-desbloqueada | **SIM** |
| Design completo | **SIM** |
| Anti-micro | **SIM** — 4 dialetos / 20+ peels |

---

## Reviewer (self · 0 critical)

| Issue | Sev | Resolution |
|---|---|---|
| Shared força copy Arena errada | critical if | domainUnavailable slot obrigatório |
| Quebra WAVE-003 fail≠empty | critical if | regression check explicit DoD3 |
| A11y ID break | major | preserve identifiers |
| Scope Artifact/ChangeReview empty | minor | out of scope |

**Critical open:** 0.

---

## §5

Nenhum. Kinds de rede já no model/session. Domain-unavailable já em `ArenaModel`.

---

## Approval

- [x] §B pass  
- [x] Sections complete  
- [ ] `approved` — auto-approve rank≤2 OK (rank 3: prefer operator/Implementer judgment)

## Explores

- explore pill/chat/Arena: WAVE-v4-003 ops-failure  
- explore Autonomos: 4 dialects  
- v3 LEDGER WAVE-006 candidate  
