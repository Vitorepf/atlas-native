# WAVE-103 — markdown-blocks-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-103-markdown-blocks-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer self-WAVE · residual full-bar)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · after 2 IDLE · fila vazia)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `AtlasMarkdownSurface` embute **3 enums A11y** (list/quote/code) no
  meio do renderer — dialeto de VO misturado com layout.
- Operador escuta blocos de resposta do assistente sem órgão Judgment.
- Residual pós-TurnPresence-102 + IDLE camera/conversation: markdown órfão.

## Patamar

| Antes | Depois |
|---|---|
| MarkdownBlocksA11y soup | **AtlasMarkdownJudgment** |
| CodeBlockA11y copy/lang | Judgment spoken family |
| Quote/list local | Judgment only |

Δ = **soberania dos blocos markdown** — list/quote/code/copy uma língua.

---

## Arquitetura

### Princípios

- Casca only. Plain text from rendered spans; never invent content.
- Judgment pure Foundation.
- Zero Core · zero tipografia change.

### Fluxo

```
plain · lang · lineCount · copied?
  → AtlasMarkdownJudgment
       spokenListItem · spokenQuote · spokenBlock
       spokenCopyButton · copyHint · langLabel
  → Surface / Blocks wire
  → delete 3 A11y enums
```

### Arquivos (≥5)

1. `AtlasMarkdownJudgment.swift` (**new**)
2. `AtlasMarkdownSurface.swift`
3. `AtlasMarkdownBlocks.swift`
4. CODEMAP
5. design + compress

### Densidade

Judgment ~100–160 · Surface −80 A11y

### Fora de escopo

- Markdown parse Core  
- New block types  
- Tipografia  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] AtlasMarkdownJudgment spoken list/quote/code/copy.
- [ ] Delete MarkdownBlocksA11y + Quote + CodeBlockA11y.
- [ ] Blocks + Surface Judgment-only.
- [ ] langLabel pure helper on Judgment.
- [ ] packFacts optional for block kinds if useful.
- [ ] Gates + CODEMAP + DEVICE_PENDING.

## Anti-objetivos

- inventar plain text  
- tipografia  
- fundir com EditorialTurn  

## Plano W3

1. New Judgment.  
2. Rewire Surface/Blocks.  
3. Delete enums.  
4. CODEMAP.  
5. ~5 files · ~150–300 LOC.

## Proof

1. Ordered list item spoken includes index.  
2. Empty quote → "citação vazia".  
3. Code block without lang → "linguagem não informada".  
4. Copy disabled when empty.  
5. DEVICE_PENDING.

## Council

Residual after Continuity-102. Completes assistant prose chrome.

### Rejection

Enums remain → fail.

### Spoken table

| Block | Spoken seed |
|---|---|
| list ordered | item N, text |
| list bullet | text |
| quote | citação, text |
| code | bloco de código, lang, lines |
| copy | copiar código / copiado |

### Pack optional

```
md_block_kinds: list|quote|code
absence: bloco vazio
```

Keep pack thin — presence of helpers is DoD; call site optional on host.

### W2/W3

Standard DONE/compress/regen/LEDGER/gates.

### Why full-bar

- New Judgment · 3 enum delete · ≥5 files · product VO for assistant body  

---

*End WAVE-103 design.*
