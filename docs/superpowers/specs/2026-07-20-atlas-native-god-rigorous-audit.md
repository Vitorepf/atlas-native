# Revisão rigorosa multi-agente — Atlas Native GOD

**Data:** 2026-07-20  
**Método:** 6 subagents em paralelo (plano F0–F10 · dead code · honesty · abstrações · Continuity/self-construction · pílula matrix)  
**Canon:** master plan v2 `2026-07-20-atlas-native-god-version-master-plan.md`  
**Veredito:** o GOD v2 tem a **ordem de doutrina certa** (fundação antes de polish), mas é **plano de prioridade, não de implementação**. Falta operacionalizar cada F*, fechar conflitos de doutrina, e mapear órgãos omitidos (Conversa sink, Review, UITests, N8 mid-wave).

---

# 1. Veredito em uma página

| Eixo | Nota | Comentário |
|---|---|---|
| Doutrina (pack, grafo, self-construction, Continuity) | **Forte** | Cânone operador 2026-07-20 está no master v2 |
| Operacionalização F0–F10 | **Fraca** | ~197 linhas; sem owners/paths/UITest por onda |
| Delete / de-factor | **Alvo claro** | Arena classic ~110–130 files; SelfConstruction ~31 órfãos; peels hell |
| Honesty bugs | **P0 reais** | tool_permissions read; grafo dual headline; App Group off |
| Superfícies omitidas no F* | **Grave** | Conversa/Review/RichInput/Search/LiveNow quase só “F9 craft” |
| Conflito hop vs “não misturar mundos” | **P0 docs** | pill.md vs GOD v2 — precisa OBRA §6 |

**GOD perfeito exige:** master v2 + **este audit** + expandir cada F* em contrato/owner/paths/prova.

---

# 2. Matriz de ações (refatorar · defatorar · otimizar · corrigir · melhorar · abstrair)

## 2.1 CORRIGIR (honesty / verdade)

| # | Item | Path / prova | Owner | Onda |
|---|---|---|---|---|
| C01 | `tool_permissions` sempre `read` | `TurnPayloadBuilder.swift` + checks | Codex | F7 |
| C02 | Model “N desvios” vs UI “sem retorno” + dual contagem | `AtlasCodeModel+State` · GraphChrome · §5 | Codex+Fable | F2 |
| C03 | App Group removido → Continuity morta | entitlements App+Widgets | Operador+Codex | F3 |
| C04 | Arena destination: invite OK, **facts/suggestions sempre `.now`** | `ArenaPremiumDestinationView.swift` | Fable | F4 |
| C05 | Self-construction: heal `merge_performed=false`; delivered=0 | evidence selfconstruction · M01 | Codex/server | F1 |
| C06 | SelfConstruction UI **0 consumers** | `SelfConstructionReceipt*` | Fable | F1 |
| C07 | Overclaim invites (“Roda…”, “Pare…”) sem do NL | ArenaAskContext / Autonomos | Fable | F4/F7 |
| C08 | Widget timer `ms ?? 0` → 0:00 mentiroso | LiveSession timer helpers | Fable | F3 |
| C09 | Conflito doutrina hop vs pill “não misturar” | pill.md · master · OBRA §6 | Operador+docs | F0 |
| C10 | Radar a11y “desvios” residual | AtlasCodeRadar*A11y | Fable | F2 |

## 2.2 DELETAR / DEFATORAR (dead · dual-stack · peels)

| # | Item | Estimativa | Risco | Onda |
|---|---|---|---|---|
| D01 | **Arena classic dual-stack** (Now/Index/Suites/Capabilities/EngineSheet + peels body mortos) | **~110–130 files / ~3k LOC** | Baixo se keep Premium/Run/Suite/Chart | **Paralelo F1–F5** (não adiar F8) |
| D02 | `AtlasCodeSwipeToAsk` (0 consumers) | 1 file | Mínimo | F2 hygiene |
| D03 | Shells `extension {}` vazios (~42 hits) | dezenas | Baixo | fuse com famílias |
| D04 | Residual Autônomos refresh no-op peels | poucos | Baixo | F6/F8 |
| D05 | SelfConstruction: **delete só se** decisão não rewire | ~31 | Médio produto | F1 decisão |
| D06 | LoadedSection Autônomos | **já 0** | — | — |

**NÃO deletar na D01:** `ArenaPremium*`, `ArenaRunSheet*`, `ArenaSuiteSheet*`, `ArenaCompositeChart*`, `SuiteSparkline*`.

## 2.3 FUNDIR / DEFATORAR peels (TOP fuse)

| # | Família | ~files | Ação |
|---|---|---|---|
| U01 | AtlasCode* | ≥200 | Fuse AskPill 12→2–3; GraphList; A11y |
| U02 | Conversation* | ≥120 | Sheets 4-hop→1; messages/cockpit |
| U03 | Widgets Accessories+Turn | ≥145 | A11y bind towers; Island branches |
| U04 | Root/Home/LiveNow/Search | ≥70+55+41 | Fuse LiveNow 55→~8; Search; destinations |
| U05 | A11yID* | ~57 | Fuse por domínio ~8 files |
| U06 | ArenaRunSheet* | ~48 | Fuse a11y 1-string peels |
| U07 | ChangeReview + Execution + Artifact | ≥150 | Fuse micro-labels |
| U08 | Dock pílula×3 (Arena shell/dest/Autônomos) | 3 cópias | **1 AgenticPill dock** |
| U09 | ISO parse local (ArenaDisplay, CodeScan) | 2 | → `AtlasTime.date` |
| U10 | Ink widgets vs Theme | WidgetsInk | Shared tokens |

## 2.4 ABSTRAIR (só 2º consumidor real)

| # | Abstração | Consumidores reais | Onda |
|---|---|---|---|
| A01 | **`AgenticPill`** (chrome único; rename fora de ArenaPremiumAskPill) | Home, Arena, Autônomos, (+Code) | F7 early / paralelo F2 |
| A02 | **Dock+sheet** de conversa ask | 3× copiado | F7 |
| A03 | **MapChrome** kicker/hairline/CTA | AutonomosMap + ArenaPremium | F5/F6 craft |
| A04 | Failure chrome genérico | Code/Arena/Autonomos empties | F8 |
| A05 | **NÃO** criar: protocol packs, framework genérico, newPill=Workspace fundido com ask |

## 2.5 OTIMIZAR (perf / N8)

| # | Item | Path | Onda |
|---|---|---|---|
| O01 | Coalesce change-review refresh (hoje 3 GET/bolha assistant) | `ConversationMessages+Rows` · ChangeReviewModel | F9 / paralelo |
| O02 | `violatingHashes` recompute caro | AtlasCode model | F2/Codex |
| O03 | Baseline Instruments **antes** F5/F8 | evidence/perf-baseline | **Toda onda** + F10 |
| O04 | Home defer refresh Arena/Code | Root lifecycle | F9 |
| O05 | WidgetCenter.reload após snapshot write | Writer | F3 |

## 2.6 MELHORAR / COMPLETAR (produto alicerce)

| # | Item | Owner | Onda |
|---|---|---|---|
| M01 | Self-construction M01 a|b + UI rewire | Codex+Fable+Operador | F1 |
| M02 | Packs Core + hop policy + turnFacts→schema | Codex | F4 |
| M03 | Grafo glance 5s canônico | Codex+Fable | F2 |
| M04 | Continuity App Group + WidgetCenter + Island | Operador+Codex+Fable | F3 |
| M05 | Arena E2E real (worker) + engine/cases §5 | Codex+Operador | F5 |
| M06 | Autônomos POST create | Codex | F6 |
| M07 | NL→ação governada (reuso sheets) | Fable+Codex | F7 |
| M08 | **Onda S Conversa/Review/RichInput** (omitida no F*) | Fable | **entre F4 e F7** |
| M09 | Arena LA + App Intents (M61/M89) | Codex+Fable | F3 stretch |
| M10 | M65 notif text→queue (delegate Nightly) | Codex+Fable | F3/F9 |

---

# 3. Superfícies que o F0–F10 **omite** (grave)

| Superfície | Por que deve entrar no GOD | Onda sugerida |
|---|---|---|
| **Conversa sink** (composer, fila, cockpit, proof) | U1–U3; verbo real diário | **F4.5 / S** |
| ChangeReview / Artifacts / Council | Fidelity 07/10/12 | S |
| Search / Workspace / LiveNow | Rotas vivas; peels | F9 + fuse cedo |
| Rich input / Draft / Camera | U1 DEVICE | S |
| Code Radar / Why / Provenance | Julgamento além spine | F2 expand |
| Nightly / Rhythm | 21h; device-pending | F6 decision |
| Fable fidelity 01–13 | Quase tudo PARCIAL | mapear → F* |

---

# 4. Dead code — kill list (com prova)

| Alvo | Evidence | Ação |
|---|---|---|
| Arena classic chain | body só Premium; `arenaScrollBody` 0 leitores | **DELETE** ~110–130 files |
| `selectedEngine` / `suitesExpanded` | só classic | limpar state host |
| `AtlasCodeSwipeToAsk` | 0 consumers | **DELETE** 1 file |
| SelfConstruction sheets | 0 `SelfConstructionReceiptSheet(` | rewire **ou** delete |
| `extension {}` shells | ~42 | fuse/delete com família |
| AutonomosLoadedSection | **já 0** | — |

**Prova pós-delete Arena:**
```bash
rg 'arenaScrollBody|ArenaNowSection\(|ArenaIndexSection\(|ArenaSuitesSection\(|ArenaEngineSheet\(' App/
swift run AtlasCoreChecks && cd App && make build
```

---

# 5. Pílula — buracos F4/F7 (matrix)

| Superfície | Pill | Pack | Do NL |
|---|---|---|---|
| Home | visual partida | ✗ | fraco |
| Workspace | visual new | ✗ | fraco |
| Code graph | ✓ | **forte** facts | fraco (read) |
| Code radar | ✗ | — | — |
| Arena tabs | ✓ | presentation | overclaim |
| Arena dest | ✓ | **BUG `.now`** | overclaim |
| Autônomos | ✓ | thin | local/§5 |
| Search/Review | sem pílula (ok deliberável) | — | — |

**P0 pílula:** F0 hop doctrine · F4 schema+destination fix · F7 tool_permissions.

---

# 6. Continuity + Self-construction — checklists P0

### Continuity (C-01…C-43 resumido)
1. **Operador:** App Group portal + APNs vault + passcode  
2. **Codex:** entitlements + writer prova  
3. **Fable:** WidgetCenter reload + Island + widgets  
4. Stretch: Arena LA · App Intents · M65  

### Self-construction (S-01…S-19 resumido)
1. **Operador:** decisão M01 (a) merge bridge vs (b) heal-receipt  
2. **Codex/server:** implementar + probe delivered  
3. **Fable:** rewire recibo quando dados reais  
4. **Nunca** fabricar merge  

---

# 7. Contradições a resolver em F0 (docs)

| # | Conflito | Resolução |
|---|---|---|
| 1 | GOD hop livre vs pill “não misturar mundos” | §6: pack puro + intenção livre + anexar pack local |
| 2 | Master F0–F10 vs companion peels W0–W11 72h | Companion só inventário; ordem = master |
| 3 | N8 só F10 vs N8 lei contínua | Smoke N8 em toda onda; baseline F10 |
| 4 | Chrome pílula F7 vs precisava cedo | Chrome paralelo Fable desde F2 |
| 5 | Delete classic F8 vs body já Premium | Delete **paralelo cedo** (higiene) |
| 6 | Widgets “mortos” vs código completo | F3 = **ligar** group, não reescrever |

---

# 8. Ordem de execução corrigida (pós-audit)

```
F0   §6 hop+pack · inventário morto · fidelity map
F1   Self-construction M01 + UI
F2   Grafo sem retorno canônico + pack + hygiene SwipeToAsk
F3   App Group + Continuity live
F4   Packs Core + hop + fix destination .now
S    Conversa/Review/RichInput (NOVA onda formal)
F5   Arena E2E + delete classic (higiene paralela desde F1 ok)
F6   Autônomos create
F7   tool do + AgenticPill chrome + NL ações
F8   Fuse peels TOP20 + residual delete
F9   Craft + a11y + RM + DT
F10  N8 baseline + DEVICE_PROVEN + DoD

PARALELO SEMPRE: boundary checks · delete classic Arena · fundir hops vazios
```

---

# 9. Definition of Done GOD (enriquecido pelo audit)

Além do master v2:

- [ ] Cada F* tem: owner · paths · acceptance · UITest · device · §5 ids  
- [ ] Kill list Arena classic executada (rg=0)  
- [ ] Self-construction: 1 ciclo real **ou** heal-receipt + UI  
- [ ] Grafo: uma voz “sem retorno” model+UI+radar  
- [ ] App Group: widget atualiza após sessão real  
- [ ] Destination Arena: facts ≠ sempre Agora  
- [ ] tool_permissions: política documentada (não hardcode eterno sem ADR)  
- [ ] Onda S Conversa não omitida  
- [ ] Matriz UITest pílula × superfície  
- [ ] N8 baseline numbers em evidence  

---

# 10. TOP 30 backlog unificado (prioridade brutal)

| # | Ação | Tipo | Owner |
|---|---|---|---|
| 1 | M01 self-construction close | corrigir/completar | Codex+Op |
| 2 | App Group portal + entitlements | corrigir Continuity | Op+Codex |
| 3 | Delete Arena classic dual-stack | deletar | Fable |
| 4 | Grafo sem retorno no model | corrigir | Codex |
| 5 | Fix destination pack `.now` | corrigir | Fable |
| 6 | Pack schema Core + hop §6 | abstrair/contrato | Codex |
| 7 | tool_permissions policy | corrigir | Codex |
| 8 | Rewire SelfConstruction UI | completar | Fable |
| 9 | AgenticPill chrome + dock único | abstrair/fundir | Fable |
| 10 | Coalesce change-review refresh | otimizar | Fable/Codex |
| 11 | WidgetCenter reload | corrigir | Fable |
| 12 | Autônomos POST create | completar | Codex |
| 13 | Onda S Conversa fidelity | completar | Fable |
| 14 | Fuse A11yID 57→8 | defatorar | Fable |
| 15 | Fuse Code AskPill peels | defatorar | Fable |
| 16 | Fuse LiveNow/Search/Root | defatorar | Fable |
| 17 | Fuse Conversation sheets | defatorar | Fable |
| 18 | Fuse Widget a11y towers | defatorar | Fable |
| 19 | AtlasTime only (delete parseISO dup) | fundir | Fable |
| 20 | Ink=Theme widgets | fundir | Fable |
| 21 | Delete SwipeToAsk + empty shells | deletar | Fable |
| 22 | Calibrar invites ao can-do | melhorar | Fable |
| 23 | Arena engine/cases §5 | completar | Codex |
| 24 | NL→run/stop/heal | completar | Fable+Codex |
| 25 | M65 notif→queue | completar | Codex+Fable |
| 26 | Arena LA M61 | completar | Codex+Fable |
| 27 | App Intents M89 | completar | Codex+Fable |
| 28 | UITest pílula×superfície | prova | Fable |
| 29 | N8 Instruments baseline | otimizar/prova | Op |
| 30 | DEVICE_PROVEN prints | prova | Op |

---

# 11. O que o audit **não** pediu inventar

- Framework genérico de packs na casca  
- Wall cross-world  
- Fabricar delivered/merge  
- Voice / Route nova / SPM  
- Fundir Workspace newPill com pílula agêntica  
- Big-bang rewrite  

---

# 12. Handoff

1. **Operador:** ler TOP 30; decidir M01 a|b; App Group portal; passcode.  
2. **Docs:** este audit + master v2 = par canônico.  
3. **Implementação** (`IMPLEMENTAR AGORA`): F0 (hop §6) + F1 kickoff + D01 delete Arena classic em paralelo + C04 destination fix (quick win Fable).  

---

*Auditoria 6 agentes · 2026-07-20 · refatorar/defatorar/otimizar/corrigir/melhorar/abstrair sem vaidade de LOC.*
