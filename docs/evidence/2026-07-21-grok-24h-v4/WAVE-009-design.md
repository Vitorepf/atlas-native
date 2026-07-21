# WAVE-009 — codigo-depth-instrument

**Status:** design · proposed  
**Wave:** `WAVE-009-codigo-depth-instrument`  
**Owner:** casca only (Implementer)  
**Date:** 2026-07-21  
**Created by:** designer (v4 dual)  
**Δ patamar:** **high**  
**Rank:** 4  

---

## Problema

WAVE-001 fechou o **glance de 5s** no grafo (âncora, sem retorno, pílula Radar,
emptyPrompt contínuo). O residual GOD de Código **não** é outro chrome de mapa —
é a **segunda metade da soberania**: abrir um commit / arquivo / cura e ainda
sentir o **mesmo órgão de julgamento**.

Hoje:

1. **Provenance / Why / Heal / Mirror / FileRow** existem (~130 peels, ~2.3k LOC
   só nessas famílias) mas falam com gramática irregular (peel fog, snake residual
   risk, a11y espalhado).
2. **Why (H1)** — biografia do arquivo — é prioridade da evolução Código, mas
   ainda não é drill first-class a partir do grafo (sheet utilitário, não
   instrumento).
3. **Heal / Mirror** — receipts e quiet-healthy existem; a história “Atlas
   curou sem você” compete com ruído de peel; silence-when-healthy nem sempre
   é a voz dominante.
4. **Perguntar** a partir de provenance deve **só** ancorar a pílula (WAVE-001
   lei) — nunca hijack de modal.

Dual-count obra/branch no banner vs linhas = **§5 Core** — casca **não** inventa
reconciliação; declara incerteza se preciso.

---

## Patamar

| Antes | Depois |
|---|---|
| Glance mapa GOD; depth peel-fog | Depth = **mesmo instrumento** (estado · lei · files · why · cura · ask) |
| Why secundário | File → Why quando target existe; absence honesta |
| Heal/Mirror ruidosos quando saudáveis | Silence-when-healthy; vocab “sem retorno/curado” |
| 130 peels | Torre fundida; hosts ≤400 |

Δ = soberania **pós-glance** (julgar um nó, não só a lista).

---

## Arquitetura

### Princípios

- **Uma voz com o mapa:** “sem retorno” / curado / main / fora — zero “desvios”
  na cara; zero snake_case de wire na UI.
- **Provenance sheet = instrumento**, não dump: estado · corpo · lei · files ·
  CTA perguntar (ancora pill only).
- **Why:** se target/ledger existe, cadeia legível; se não, absence explícita
  (nunca inventar quote de commit).
- **Heal receipt:** só dados model; silence se vazio.
- **Mirror:** quiet when healthy — sem check decorativo.
- **Casca only.** Agent filter DTO, dual unit banner, tool write = §5.
- **W3** funde peels Why/Provenance/Heal/Mirror; proíbe collapse into
  `AtlasCodeView` god-host.

### Fluxo

```
tap commit → Provenance instrument
  → file row → Why (if target) else honest absence
  → “perguntar” → askFocusNode + draft (não abre conversa sozinho se lei atual
      for swipe-first; paridade WAVE-001)
  → heal receipts se existirem
mirror card on graph: quiet | blocked | healthy (model)
```

### Fora de escopo

- Metal/Kraken graph.
- Agent-filter chips sem DTO.
- Mandar-curar via chat (tool_permissions).
- Redo WAVE-001 âncora/emptyPrompt.
- Arena / Autônomos.

---

## Arquivos (W2)

| Área | Mudança |
|---|---|
| `AtlasCodeProvenanceSheet*` | Instrument body; PT only; ask anchors pill |
| `AtlasCodeWhySheet*` | Drill legível; absence path |
| `AtlasCodeFileRow*` | Verbs + path → Why |
| `AtlasCodeHealReceiptSheet*` | Vocab alinhado; silence empty |
| `AtlasCodeMirrorCard*` | Quiet healthy |
| Load failure nestes sheets | Prefer WAVE-008 shared se já landed; senão local honesty |
| A11yID Code provenance/why/heal | Estáveis |

### W3

| Alvo | Estimativa |
|---|---|
| Fuse Provenance/Why/Heal/Mirror peels | **−300…−700** |
| Delete morto | −50…−100 |

`WAVE-009-compress.md`.

---

## DoD (≥5)

1. Tap commit → sheet fala estado/lei em português legível (sem snake_case na cara).
2. File row → Why quando target existe; absence honesta sem quote inventada.
3. Provenance “perguntar” só ancora pílula (sem hijack modal que quebre WAVE-001).
4. Heal: vocab “sem retorno/curado”; silence se sem receipts.
5. Mirror quiet quando healthy (sem check decorativo).
6. Failure load nestes sheets não vira empty de dados inventados.
7. Fuse peels; hosts ≤400; gates verdes.

---

## Anti-objetivos

- Só fuse a11y spine sem DoD de instrumento.
- Inventar reconciliação dual-count.
- Agent chips fake.
- Collapse into AtlasCodeView host.

---

## Plano W3

DoD → fuse adjacentes mesma feature → delete dead → numstat.

---

## §B

| Critério | Pass? |
|---|---|
| Patamar | **SIM** — depth soberania |
| DoD≥5 + multi surface sheets | **SIM** |
| Casca | **SIM** |
| Design | **SIM** |
| Anti-micro | **SIM** (~130 peels) |

---

## Reviewer · 0 critical

| Issue | Sev | Fix |
|---|---|---|
| Why sem ledger mente | critical if | absence path only |
| Ask hijack | major | WAVE-001 parity |
| Dual-count claim | major | never claim reconcile |

**Critical open:** 0.

---

## §5 (não bloquear)

- Dual unit banner vs issue lines (Codex model).  
- Agent field em graph node (M105).  
- tool_permissions write.

---

## Approval

- [x] §B  
- [x] complete  
- [ ] approved  

## Explores

- explore Code/Grafo: top #1 depth-instrument  
