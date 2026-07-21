# WAVE-001 — grafo-soberano-casca

**Status:** design · pending approve  
**Wave:** `WAVE-001-grafo-soberano-casca`  
**Owner:** casca (Fable / Grok 24h v3.1)  
**Date:** 2026-07-21  

---

## Problema

O grafo é o instrumento de **julgamento soberano** do operador (master plan §2.3 / F2): em ~5s ele deve ver trunk, sem retorno, âncora, pack e pílula — e decidir. Hoje a casca **quase** fala essa gramática, mas o órgão ainda falha em integridade:

1. **Âncora morre no sheet.** Swipe no commit refina a pílula (`askFocusNode` + `anchorLegend` + `askDraft`), mas `AtlasCodeView+Sheets+AskConversation.swift` abre a conversa com `emptyPrompt(focusLegend: nil)`. O operador ancora no mapa e o empty card ignora a âncora.
2. **Glance parcial.** `statusHeadline` / pulse já dizem “N sem retorno” e calam quando limpo — bom. Falta garantir que filtros, a11y e dim pós-resposta contam a **mesma** história (sem vocabulário morto “desvios”, sem âncora contraditória, truncation honesta).
3. **Pílula Code ainda é floresta paralela.** ~14 peels AskPill + chrome próprio; `AgenticPill` unifica Arena/Autônomos, Code não. Não é só estética: slots de âncora/clear existem, mas a máquina da pílula não é uma.
4. **Radar (folha de julgamento) sem verbo.** Hub/grafo têm pílula; Radar não — superfície de julgamento sem porta de intenção (lei pílula).

Isto **não** é polish de label. É o baseline de soberania do operador no grafo.

---

## Patamar

**Antes:** grafo = lista de commits + pílula que às vezes mente sobre o foco; Radar sem pílula.  
**Depois:** operador julga em 5s com **uma voz** (pulse · filtros · âncora · emptyPrompt · pack · clear) e pode **perguntar** de qualquer face de julgamento Código (grafo + radar) sem inventar Core.

Δ = capacidade de julgamento + honestidade do instrumento (não copy isolado).

---

## Arquitetura

### Princípios
- **Casca only.** Zero edits em `Sources/**`, `ConversationModel.swift`, `AtlasSession.swift`. Presentation-only se precisar de helper.
- **Uma verdade por fato.** Âncora = `askFocusNode` / `askModel` state; legenda = `anchorLegend`; emptyPrompt **deriva** da mesma legenda.
- **Pílula = porta; pack = inteligência.** Pack Code já viaja por `askModel.facts`; não inventar schema Core.
- **Silêncio quando são.** Pulse limpo = nil (já); não inventar status “tudo bem!” ruidoso.
- **Peels servem compressão, não identidade.** W3 funde peels AskPill/Graph micro; hosts ≤200 alvo, hard fail >400.

### Fluxo âncora (corrigido)

```
swipe commit / provenance “perguntar”
  → askFocusNode + askDraft + haptic
  → pill caption = anchorLegend (swipeFocusLegend)
  → tap pill → sheet ConversationView
       emptyPrompt = emptyPrompt(focusLegend: anchorLegend)  // FIX
       draft = askDraft
       turnFacts = askModel.facts
  → answer → dim nós + anchorNote na pílula
  → clear → mapa restaura, legenda some
```

### Radar (escopo desta onda)

Radar é **folha de julgamento** do hub Código. Nesta onda:

- Dock da **mesma** família de pílula (preferir `AgenticPill` ou o chrome Code unificado pós-fuse).
- Pack presentation-only a partir de dados **já** no model/radar (repo, pastas, contagens de sem retorno se expostas). Sem campo Core novo.
- Ask path = mesmo sheet Code (`taskKind: code`, workspace = repo).

Se Radar model não expuser o mínimo para um pack honesto sem teatro: pílula com pack **mínimo** (repo + “radar”) e absences explícitas — nunca inventar scan results.

### Fora de escopo (anti-teatro)
- Dual contagem obra/branch canônica (§5 Core).
- Formatador único se exigir mudar lógica de model dona do Codex — só presentation-only.
- NL mandar-fazer / tool write.
- Metal/Kraken graph toy.
- Arena / Home / Autônomos (outras waves).

---

## Arquivos

### W2 — comportamento (edit expected)

| Path | Mudança |
|---|---|
| `App/Atlas/AtlasCodeView+Sheets+AskConversation.swift` | `emptyPrompt(focusLegend:)` com legenda viva (não `nil`) |
| `App/Atlas/AtlasCodeView+Ask.swift` | garantir draft/focus alinhados ao open do sheet |
| `App/Atlas/AtlasCodeView+Anchors.swift` (+ Partial/Visible se preciso) | legenda única consumida por pill **e** sheet |
| `App/Atlas/AtlasCodeAskContext.swift` | emptyPrompt/suggestions honestos com focus |
| `App/Atlas/AtlasCodeGraphChrome+Status.swift` | glance: pulse coerente; a11y headline |
| `App/Atlas/AtlasCodeGraphStateFilter+Label*.swift` | labels main/fora/healed; zero “desvios” na cara |
| `App/Atlas/AtlasCodeView+GraphListTail+Truncation.swift` | truncation caption quando `hasMore` (verificar host path) |
| `App/Atlas/AtlasCodeView+AskPill*.swift` | slots âncora/clear; preparar fuse W3 |
| `App/Atlas/AtlasCodeRadar*.swift` (host shell + 1–2 peels) | dock pílula + open ask com pack mínimo |
| `App/Atlas/A11yID+Code*.swift` | IDs estáveis radar pill / truncation se faltar |
| peels de dim/answer se existirem | `anchorNote` + clear restaura |

### W3 — compressão (mesmo wave)

| Área | Alvo |
|---|---|
| `AtlasCodeView+AskPill*` (~14 files) | fundir → 2–3 reais (content/chrome · a11y · anchors/clear) |
| GraphChrome/GraphList micro-peels 1-string | fundir adjacentes sem collapse-host |
| Radar a11y 1-string peels tocados | fundir só no escopo da pílula |

**Proibido W3:** opacity token ladder; chase file-count; god-file >400; colapsar “into host”.

### Não tocar
- `Sources/**`, `ConversationModel.swift`, `AtlasSession.swift`, Makefile, project.yml
- Arena/Autônomos/Home (exceto se AskConversation sheet API for shared type — only Code path)

---

## DoD (≥5 — todos observáveis)

1. **Âncora contínua:** swipe em commit → pílula mostra legenda do commit → abrir pílula → empty card usa a **mesma** legenda (`sobre {legenda} — …`), não o convite genérico.
2. **Clear restaura:** clear na pílula remove foco, draft e volta caption ao invite; mapa sem dim residual de âncora de swipe.
3. **Resposta ancora com honestidade:** após ask com resposta de âncoras, pílula mostra `anchorNote` / partial (“N acesas de M citadas”) quando já suportado; não inventa contagem.
4. **Glance sem retorno:** com violações, pulse central = `statusHeadline` (“N sem retorno”); limpo = silêncio (sem pulse); unknown = headline de falha de varredura.
5. **Truncation:** com `pagination.hasMore`, caption “há mais história” (ou copy canônica existente) visível e com a11y id.
6. **Filtros grafo:** tabs main / fora / healed (e todos) legíveis; zero string “desvios” em UI Code casca tocada por esta onda.
7. **Radar pílula:** de Radar, operador abre pílula e chega em conversa Code com workspace=repo e facts mínimos honestos (sem inventar issues).
8. **Gates:** `swift run AtlasCoreChecks` + `cd App && make build` verdes; `./scripts/grok-god-wave-guard.sh` OK; nenhum `*View*/*Shell*` >400.

---

## Anti-objetivos

- Não “melhorar copy” de um label e chamar de wave.
- Não reintroduzir dual-stack Arena classic.
- Não inventar API Core de contagem obra/branch.
- Não fingir NL write tools.
- Não collapse peels into god hosts.
- Não token-opacity como compressão.
- Não área/tab/rota nova.
- Não mexer em ConversationModel lógica.

---

## Plano W3 (ΔLOC alvo)

| Alvo | Estimativa |
|---|---|
| Fuse AskPill tower | −200 a −400 LOC líquidos (delete peels + keep behavior) |
| Graph micro-peels adjacentes tocados | −100 a −200 |
| Radar pill peels residual se criados demais | net ~0 a −50 após fuse |
| **Meta onda W3** | **≥800 LOC líquidos** no escopo grafo/radar peels **ou** prova honesta se o fuse real for menor (ainda assim W3 reporta `git diff --numstat`) |

Se fuse honesto <800: ainda completar W3 com relatório honesto; o §B da onda já passa por DoD≥5 + ≥3 hosts — meta 800 é **alvo de compressão**, não desculpa para collapse-host.

---

## Gates

```bash
./scripts/grok-god-wave-guard.sh
swift run AtlasCoreChecks
cd App && make build
```

Commits: `feat(ui): WAVE-001 …` only while `phase=W2_implement|W3_compress`.  
Device: operador (DEVICE-PENDING honesto se sem iPhone).

---

## Plano de implementação W2 (ordem)

1. **Fix âncora sheet** — `AskConversation` + plumbing legenda/draft (menor risco, maior Δ honestidade).
2. **Glance audit** — pulse/filters/truncation/a11y vocabulary pass on graph hosts.
3. **Answer/clear integrity** — garantir clear + anchorNote paths.
4. **Radar pílula** — dock + sheet open + pack mínimo.
5. **Self-check DoD** → phase W3.

---

## Reviewer pass (self · W1)

| Issue | Severity | Resolution |
|---|---|---|
| Radar pack inventando dados de scan | critical if ship | Only model-exposed fields; absences explicit |
| Touching AtlasCodeModel logic for dual count | critical | Out of scope; §5 |
| AskPill fuse in W2 before DoD behavior | major | Behavior first W2; fuse W3 |
| emptyPrompt only fixed, rest deferred as “later micro” | critical process | Full DoD 1–8 required before W3 |
| God-file risk fusing into AtlasCodeView.swift | critical | Keep peels under 200/host; hard fail 400 |

**Critical open after design:** 0 (Radar pack constrained; Core dual-count deferred).

---

## Approval

- [x] Passes §B (patamar + DoD≥5 + ≥3 hosts + W3 plan)
- [x] Casca-unlocked
- [x] Anti-micro
- [x] Sections complete

**design_approved:** true (when ledger flips after this file is on disk)
