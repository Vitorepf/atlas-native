# WAVE-111 — conversation-surface-density-peel

**Status:** design · proposed  
**Wave:** `WAVE-111-conversation-surface-density-peel`  
**Owner:** casca only (Grok B / Implementer self-WAVE · residual full-bar)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · after fila vazia · GOD density hard fail)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- `ConversationSurface.swift` **630 LOC** — acima do hard fail GOD
  (Shell/*View peels de rota ≤600; alvo agent-optimal 1–2 reads).
- Um arquivo mistura seed · lifecycle · presence · pack hydration ·
  composer wire · messages wire · header · toast · seal · actions.
- Residual pós-WAVE-106 mid-thread rebind: surface inchou sem peels.

## Patamar

| Antes | Depois |
|---|---|
| 630 LOC monólito peel | **3 peels** ≤250 cada |
| 1 read = multi-domínio | 1 read = 1 intenção |
| Hard fail density | Dentro da faixa |

Δ = **densidade agent-optimal da conversa** — peel canônico §7.

---

## Arquitetura

### Princípios

- Casca only. Zero lógica de model. Zero Core.
- Mesmo domínio `Conversation*` — não fundir com Home/Arena.
- MARK layout preservado em cada peel.

### Fluxo / layout alvo

```
ConversationSurface.swift          seed · lifecycle · presence · pack 106
ConversationSurfaceComposer.swift  composer + messages wire
ConversationSurfaceChrome.swift    header · actions · toast · seal
```

### Arquivos (≥5)

1. `ConversationSurface.swift` (thinner host peels)
2. `ConversationSurfaceComposer.swift` (**new**)
3. `ConversationSurfaceChrome.swift` (**new**)
4. `CODEMAP.md`
5. design + compress evidence

### Densidade

| File | Target |
|---|---|
| Surface seed/life | ≤200 |
| Composer | ≤260 |
| Chrome | ≤230 |

### Fora de escopo

- Core ConversationModel  
- Redesign header  
- Tipografia  
- New sheets  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] ConversationSurface.swift ≤200 LOC.  
- [ ] Composer peel owns composer+messages wire only.  
- [ ] Chrome peel owns header/actions/toast/seal only.  
- [ ] Build green · no behavior change.  
- [ ] CODEMAP topology.  
- [ ] Gates + DEVICE_PENDING.  

## Anti-objetivos

- fuse com ConversationView monólito  
- tipografia  
- reabrir WAVE-106 pack logic  

## Plano W3

1. Split by MARK domains.  
2. Verify call sites / build.  
3. CODEMAP.  
4. DONE/compress/regen/LEDGER.  
5. Estimativa: **~5 files · ~150–250 LOC moved**.

## Proof

1. `wc -l` Surface ≤200, Composer/Chrome ≤300.  
2. `make build` green.  
3. Mid-thread rebind still in Surface seed/life file.  
4. DEVICE_PENDING.

## Council

GOD hard fail 630→peels. Residual density after pack-106.

### Rejection

Rename-only without size under hard fail → fail.

### Why full-bar

- ≥5 files · density product for IA · DoD≥5 · design ≥120  
- Not IDLE: multi-file structural peel of over-limit surface  

### Related

- ConversationView host stays entry  
- SheetsBody already separate  

### Sequence after

1. IDLE thin wrappers (ArenaRunSheet) if ROI  
2. Wait A or next residual full-bar  

---

*End WAVE-111 design.*
