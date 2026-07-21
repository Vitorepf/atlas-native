# Atlas Native — PLANO MESTRE GOD VERSION (v2 · cânone operador 2026-07-20)

**Status:** Doutrina de planejamento revisada multi-agente.  
**Não implementar** até o operador escrever: `IMPLEMENTAR AGORA`.  
**Data:** 2026-07-20 · **Rev:** v2  

**Supersede / reordena:** `docs/superpowers/plans/2026-07-20-atlas-native-god-refactor.md`  
(W0–W11 peels-first → **F0–F10 fundação-first**)

**Em conflito:** `OBRA §6` > **este plano** > specs de onda > chat.

**Companions:** `OBRA.md` · `docs/engineering-knowledge-base/atlas-native-agentic-pill.md` · `docs/prompts/grok-atlas-native-full-refactor.md` · Onda1 Autônomos design.

---

# 0. Missão (uma frase)

> O operador **dirige** em linguagem natural com **contexto perfeito da ocasião**; o Atlas **age 24/7** (inclusive melhorando o próprio app), **prova** o que fez e só **interrompe** para julgamento — sem o humano no loop de ops.

---

# 1. North star

| Papel | Função |
|---|---|
| **Operador** | Intenção · Julgamento · Assinatura · Veto · **análise soberana** (grafo) |
| **Agente (Atlas)** | Execução 24/7 · self-construction · medição · cura · frota |
| **App nativo** | Casca fina — **não** IDE para programador humano |

**GOD =** eliminar o inútil + **completar o alicerce** + compressão a serviço da pureza (não trophy LOC).

**Lição Vestcode/RN:** app para programador humano inchado morre. Atlas = organismo para **operador soberano**.

---

# 2. Órgãos vitais + alicerce

## 2.1 Pílula — inteligência via pack perfeito

| Lei | Texto |
|---|---|
| Pack da tela | `surface · subject · anchors · facts · absences` — completo e estruturado |
| Inteligência = pack | Ambiguidade funciona **por causa do contexto**, não do LLM “mágico” |
| **Intenção livre** | Cross-world **NÃO se bloqueia** (Grafo→Autônomo, Arena→frota). Bloquear = burrice |
| Pack viaja | Em hop cross-world, pack **local** (commit, run, aba…) **anexa sempre** |
| Pack ≠ dump | Proibido misturar facts por acidente; permitido hop intencional governado |
| Ask + Do | Responde; faz governado **ou** recusa estruturada |
| Um chrome | Home craft; só o convite muda |
| Baseline | Superfície ops sem pílula contextual = falha de produto |

### Packs no repo (estado)

| Superfície | Pack | Nota |
|---|---|---|
| Código | **Mais forte** (`askCode` facts) | Do limitado |
| Arena | Presentation-only | §5 Core pack ABERTO |
| Autônomos | Local thin | Create §5 |
| Home | Partida | Sem turnFacts |

**Barreira do:** `TurnPayloadBuilder` força `tool_permissions: read` — NL “mandar fazer” via chat fica teatrinho até Codex.

## 2.2 Continuity — baseline (não polish)

- Island · Lock · Widgets · deep links  
- **App Group REMOVIDO** → widgets efetivamente mortos  
- **P0:** portal + entitlements + snapshot + staleness  
- Silêncio se saudável  

## 2.3 Self-construction — **ALICERCE P0**

> Atlas que não melhora o próprio app não é agente 24/7.

| Item | Status |
|---|---|
| Scanner + healer R2 + worker | DONE (server) |
| Heal `merge_performed` / delivered app | **ABERTO** (M01) |
| UI SelfConstruction* | **ÓRFÃ** (0 call sites) |

**P0:** bridge heal→merge **ou** heal-receipt; rewire/delete UI; 1 prova device.  
Arena/benchmarks = **o que** melhorar; self-construction = **como** o organismo se melhora (já deveria estar pronto).

## 2.4 Grafo (essência Vestcode / Git-Kraken) — **BASELINE julgamento**

**Fora do loop ops** (agentes trabalham sem humano).  
**Função do humano:** olhar commit, branch errada, sem retorno, merge faltando — **mínimo** da era em que o humano não programa.

**MVP 5s:** trunk · sem retorno (canônico no **model**) · âncora · pack Code · pílula.  
**Não é:** Kraken recreativo no phone.

**Gaps:** `AtlasCodeModel+State` “N desvios”; dual contagem §5.

---

# 3. Arena — instrumento (foco atual ≠ identidade diária)

Medir capacidades / motores / scores.  
**Não** home mental do dia.  
Delete dual-stack classic = higiene, não “maior ROI do programa”.

---

# 4. Ideias erradas rejeitadas (v1 → v2)

| Errado | Correto |
|---|---|
| Pack = bloquear cross-world | Pack puro + **intenção livre** |
| Grafo = armadilha / peels W4 | Grafo = **baseline soberano** |
| Self-construction = adiar | Self-construction = **P0 alicerce** |
| Continuity = fim da fila | Continuity = **baseline** + App Group P0 |
| ROI = −k LOC first | ROI = pack + merge real + glance + presença |
| Mandar-fazer sem mudar read tools | Barreira explícita Codex |

---

# 5. Três trilhos

| Trilho | P0 |
|---|---|
| **A Casca** | Dual-stack morto, peels, craft |
| **B Continuity** | App Group + snapshot + Island |
| **C Core §5** | M01 · packs · create · tool do · grafo headline · engine |

---

# 6. Ondas F0–F10

```
F0  Canon pack/intenção + inventário
F1  Self-construction close (merge/receipt + UI + prova)
F2  Grafo soberano (sem retorno model + pack + glance)
F3  Continuity restore (App Group + widgets vivos)
F4  Packs Core + hop policy
F5  Arena instrumento (E2E + pílula + delete classic)
F6  Autônomos create+persist + face v9
F7  NL mandar-fazer + chrome único
F8  Maximum delete worthless
F9  Craft Home/Conversa + a11y
F10 N8 + DEVICE_PROVEN + DoD
```

**Regra:** onda de peels que atrasa F1–F4 é **errada**.

### 72h
1. F0 docs/§6  
2. F1 claim M01  
3. F2 §5 grafo  
4. F3 status App Group  
5. Delete morto só se paralelo  

---

# 7. DoD GOD v2

- [ ] Self-construction com prova real  
- [ ] Grafo glance + sem retorno canônico + pack  
- [ ] Pílula ops + pack perfeito + cross-world **não** bloqueado  
- [ ] Continuity App Group vivo  
- [ ] Arena E2E + classic = 0  
- [ ] Autônomos create+persist  
- [ ] Boundary verde; compressão a serviço  
- [ ] checks + build + device + §7  

---

# 8. HANDOFF

**Se `IMPLEMENTAR AGORA`:** F0 + kickoff F1/F2/F3 — **não** “só peels Autônomos” como substituto do GOD.  
Autônomos compress Onda1 → F6/F8.

**Gates:** `swift run AtlasCoreChecks` · `cd App && make build` · `make device`  

**Red flags:** wall cross-world · “melhorou” sem merge · pack vazio · dual-stack · DONE sem prova  

---

# 9. Diff v1 → v2

Plano GOD antigo = **excelente compressão de casca**, fraco como “versão absoluta agêntica”.  
v2 coloca **self-construction · grafo soberano · packs · Continuity** antes de peels-first; redefine pílula (pack + intenção livre); alinha com operador 2026-07-20.

---

# 10. Âncoras de código

| Gap | Path |
|---|---|
| M01 heal-merge | OBRA §5 · `docs/evidence/2026-07-16-selfconstruction/` |
| SelfConstruction órfã | `App/Atlas/SelfConstructionReceipt*.swift` |
| statusHeadline | `AtlasCodeModel+State.swift` |
| tool_permissions read | `Sources/AtlasCore/TurnPayloadBuilder.swift` |
| App Group off | `App/Atlas/*.entitlements` |
| Arena pack | `ArenaPremiumAskContext.swift` |

---

---

# Apêndice — Revisão rigorosa multi-agente (2026-07-20)

**Doc completo:** [`2026-07-20-atlas-native-god-rigorous-audit.md`](./2026-07-20-atlas-native-god-rigorous-audit.md)

**Veredito:** doutrina F0–F10 **correta**; operacionalização **incompleta**.  
**TOP 5 imediato do audit:**
1. M01 self-construction + rewire UI  
2. App Group Continuity  
3. Delete Arena classic (~110–130 files)  
4. Grafo “sem retorno” canônico no model  
5. Pack schema + fix destination `.now` + hop §6  

**Onda formal nova:** **S** = Conversa/Review/RichInput (entre F4 e F7).  
**Paralelo sempre:** delete classic Arena · fuse hops vazios · N8 smoke.

*Plano Mestre GOD v2 + audit rigoroso — fundação antes de polish.*


---

## Progresso de implementação (2026-07-21 · sessão Grok)

### Feito na casca (gates verdes)

| Item | Prova |
|---|---|
| **Arena classic dual-stack DELETE** (~135 files) | body = Premium only; `make build` ✓ |
| **Grafo `statusHeadline` → sem retorno** | model + pulse unificados |
| **Arena destination pack** (não força `.now`) | AskContext + DestinationView |
| **SelfConstruction banner** se merge real | AutonomosMapShell + sheet |
| **Change-review coalesce** | in-flight + skip se já carregado |
| **AgenticPill** typealias chrome | `AgenticPill.swift` |
| **AtlasTime** em ArenaDisplay / CodeISO | sem parse ISO paralelo |
| **Radar a11y** sem “desvios” | sem retorno |
| **SwipeToAsk / DigestToggle** órfãos | deletados |
| Docs F0 hop note | agentic-pill.md |

### Bloqueado sem operador / server (honesto)

| Item | Bloqueio |
|---|---|
| Self-construction merge real (M01) | Server heal→merge |
| App Group Continuity | Portal Apple |
| tool_permissions write | Core+Server policy |
| Autônomos POST create | §5 Server |
| Packs Core tipados | Codex |
| DEVICE_PROVEN / N8 Instruments | Device passcode + operador |
| Fuse peels TOP20 completo | Contínuo (parcial feito) |

`swift run AtlasCoreChecks` ✓ · `cd App && make build` ✓
