# WAVE-006 — conversation-live-composer-instrument

**Status:** design · proposed  
**Wave:** `WAVE-006-conversation-live-composer-instrument`  
**Owner:** casca only (Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v4 dual)  
**Δ patamar:** **max**  
**Rank:** 1  

---

## Problema

A conversa é o órgão diário de **programação com agentes**. WAVE-003 fechou empty/fail
(sink honesto: `EmptyConversation` ≠ `AtlasNetworkFailureEmpty`). O residual que
ainda impede o patamar GOD não é copy nem tipografia — é a **superfície viva**:

1. **Instrumento de execução espalhado.** `ExecutingStrip` (~12 peels) +
   `ConversationCockpit+Reconnect*` (~12) + progress/activity + silence (já
   parcialmente fundido) contam a mesma história em árvores paralelas. O operador
   precisa de **uma** verdade visual/spoken: o que o agente faz agora, se
   reconecta, se silencia, se pode steer/stop.
2. **Composer é floresta.** ~35+ peels `ConversationComposer+*` (queue chip
   1-string, grabber bar/gestures, card body×strip×live, sheets bind flags/traces).
   O modelo de estados (idle / sending / queued / live / reconnect) já é real no
   Core/model; a casca **não inventa estados** — só os **renderiza em névoa**.
3. **Prova viva ilegível.** `ExecutionProof` + `ExecutionStateCard` (~100 peels
   combinados no ecosistema cockpit) competem com a strip sem gramática única de
   “dashboard do run”.

Isto **não** é micro-fuse de 1-string peels. É elevar o chat de agentes de
“funciona sob névoa” para **instrumento legível em 3s** durante o run.

---

## Patamar

| Antes | Depois |
|---|---|
| Live = strip + reconnect + banners paralelos | **Um** instrumento de execução viva (composição única) |
| Composer = 35+ peels micro | Composer estrutural (~8–12 arquivos reais) |
| A11y fala 3 versões do mesmo status | Uma árvore spoken alinhada ao visual |
| Empty/fail GOD (WAVE-003) | **Não regride** |

Δ = capacidade de **operar o agente em voo** (julgar, steer, stop, enfileirar)
sem decifrar a casca. Eixo transversal: toda entrada de conversa (Home, Workspace,
Code ask, Arena ask, Autônomos ask) herda.

---

## Arquitetura

### Princípios

- **Casca only.** Zero `Sources/**`, `ConversationModel.swift`, `AtlasSession.swift`,
  Makefile, project.yml. Presentation-only helpers em `ConversationModel+UI` só se
  já for o padrão e **não** mudar lógica.
- **Uma verdade por fase.** Estados vêm do model (`liveBubble`, reconnect flags,
  silence watchdog, queue count, steer receipt). A casca compõe; não inventa fase.
- **Idle / sending / queued / live / reconnect são mutuamente exclusivos** na
  face principal do composer (chip de fila pode coexistir com live — documentar
  regra: chip = fila de follow-ups; strip = run ativo).
- **Fail ≠ empty** permanece lei WAVE-003.
- **Hosts ≤400 hard.** `ConversationComposer` host, strip host, reconnect host.
- **Peels servem compressão**, não identidade. W3 funde micro; W2 entrega DoD
  de instrumento.

### Composição alvo (instrumento vivo)

```
ConversationLiveInstrument (nome ilustrativo — pode ser extension tree)
├── phase: idle | sending | live | reconnect | silence
├── title + detail (model-owned strings only)
├── progress N/M when present (never invent 0)
├── reconnect secondary (timer/loop from model)
├── actions: stop · steer · (queue open)
└── a11y: um compound label por phaseID estável
```

### Composer alvo (estrutura)

```
ConversationComposer.swift          — shell + layout
+Card / +CardChrome / +CardBody     — superfície do card
+Strip                              — toolbar + attach strip
+Live                               — monta LiveInstrument
+Queue                              — chip + sheet bind
+Steer                              — receipt + CTA
+Actions                            — send/dismiss
+A11y                               — labels/hints
+SheetsBind                         — flags/traces consolidados
```

Alvo **~8–12** arquivos estruturais no compositor; residual de a11y effort pode
ficar em 1–2 peels se >30 linhas cada — zero peels de 1 linha.

### Fluxo de estados (não inventar)

```
idle ──send──► sending ──stream──► live
                 │                   │
                 │                   ├── silence watchdog (model)
                 │                   ├── reconnect (transport)
                 │                   └── done → idle + proof
                 └── concurrent text → QueuedFollowUp (chip)
```

### Fora de escopo (anti-teatro)

- App Intents no Island / Continuity (outro wave; App Group bloqueado).
- Core `tool_permissions` write / NL mandar-fazer.
- Redesign do empty editorial (`EmptyConversation`).
- Collapse de `ConversationView` host god-file.
- Token opacity ladder como “compressão”.
- Nova tab / rota / domínio.

---

## Arquivos (W2 esperado)

| Path / área | Mudança |
|---|---|
| `ConversationCockpit+ExecutingStrip*` | Unificar em instrumento; fundir status/meta/progress/reconnect line |
| `ConversationCockpit+Reconnect*` | Entrar na mesma árvore (não segunda bolha de verdade) |
| `ExecutingStrip+*` | A11y/actions/steer alinhados ao instrumento |
| `ConversationComposer+*` | Reduzir floresta → estrutura; live strip chama instrumento |
| `ConversationComposer+LiveStrip*` | Thin wrapper → LiveInstrument |
| `ExecutionProof*` / `ExecutionStateCard*` | **Só** se necessário para legibilidade do live; preferir não reabrir proof expandido nesta onda (escopo live+composer) |
| `A11yID+*` conversation strip/composer | IDs estáveis; sem quebrar XCUITest |
| Silence watchdog residual | Garantir exclusão mútua com reconnect na face |

### W3 — compressão (mesmo wave)

| Alvo | Estimativa |
|---|---|
| Fuse ExecutingStrip + Reconnect peels | −200…−400 |
| Fuse Composer micro (queue chip, grabber 1-liners, card body splits) | −200…−500 |
| Delete morto (`rg` = 0 call sites) | −50…−100 |
| **Meta líquida** | **−400…−900** honest (DoD passa §B mesmo se &lt;800) |

Report `git diff --numstat` em `WAVE-006-compress.md`.

---

## DoD (≥5 — observável)

1. **Um instrumento vivo** na conversa: stop / steer / progress / reconnect /
   silence — **uma** árvore visual; zero dual copy de reconnect na face principal.
2. **Composer estrutural:** ≤12 arquivos `ConversationComposer*` com peels ≥1
   responsabilidade real (nada de 1-string peel file).
3. **Estados mutuamente exclusivos** na face: idle · sending · live · reconnect
   (silence como subfase live, não banner paralelo desconectado).
4. **Fail ≠ empty** preservado: load fail ainda `AtlasNetworkFailureEmpty`;
   idle empty ainda `EmptyConversation` (sem regressão WAVE-003).
5. **A11y:** phaseID estável; compound spoken alinhado ao visual; IDs de strip/
   send/queue **não quebram** XCUITest existentes.
6. **Hosts** `*View*/*Shell*` tocados ≤400 linhas; zero collapse-host.
7. Gates: `./scripts/grok-god-wave-guard.sh` · `swift run AtlasCoreChecks` ·
   `cd App && make build`.

---

## Anti-objetivos

- Fuse só de `ExecutingStrip+StatusTitle` sem DoD de instrumento (**micro**).
- Reabrir empty/fail polish.
- Inventar fases de execução não publicadas pelo model/Core.
- Opacity tokens / chase file-count.
- God-file `ConversationView` monólito.
- Tocar Island/Widgets nesta onda.
- Core / ConversationModel lógica.

---

## Plano W3 (compress)

1. Após DoD verde: mapear peels com `wc -l` + call-site `rg`.
2. Fundir adjacentes da **mesma** feature (strip, reconnect, composer card).
3. Delete dead peels com prova `rg` = 0.
4. Proibir: opacity ladder, collapse host, nova WAVE fingida.
5. Escrever `WAVE-006-compress.md` com ΔLOC medido + residual honesto.

---

## Critérios §B (mínimos WAVE)

| Critério | Pass? |
|---|---|
| Muda patamar (não copy isolado) | **SIM** — instrumento de run |
| DoD ≥5 **ou** ≥3 superfícies **ou** W3≥300 | DoD 7 + W3≥400 |
| Casca-desbloqueada | **SIM** |
| Design ≥80 linhas + Arquitetura + DoD + Anti + W3 | **SIM** |
| Não cabe em &lt;30 min / &lt;5 arquivos | **SIM** (68+ peels) |

---

## Reviewer (self · 0 critical)

| Issue | Sev | Resolution |
|---|---|---|
| Unificar strip+reconnect quebra exclusão mútua | critical if ship | Phase machine explícita no design; testar a11y phaseID |
| Composer fuse quebra send/queue | major | Preservar IDs e branch canSubmit |
| Scope creep para ExecutionProof expandido | major | Fora de DoD; residual next wave |
| W3 vira only file-count | major | Meta ΔLOC + hosts ≤400; DoD first |

**Critical open:** 0.

---

## §5 Core (se precisar — não bloquear)

Nenhum contrato novo. Se faltar campo de fase tipado no model para a11y, **não
inventar** — mapear strings/flags já expostas. Pedido Core só se Implementer
provar ausência real de sinal (improvável pós-C14).

---

## Approval

- [x] §B pass  
- [x] Sections complete  
- [ ] `approved` — Implementer/operador (auto-approve rank≤2 OK sob política v4)

## Explores (prova de ranking)

- explore conversation/pill/Arena: top #1 MAX live+composer  
- explore Continuity/Autonomos: WAVE-009 residual strip class  
- v3 LEDGER residual WAVE-003 compress  
