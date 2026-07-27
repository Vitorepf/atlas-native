# Dual Grok v5 — START (A croqui · B fábrica)

> Modo **interativo** (TUI). **Não** use `--max-turns` / watchdog headless para o dual.  
> Harness: `/always-approve` · `/effort high` · `/goal` · `/loop`.

## Papéis

| | Quem | Faz | Não faz |
|---|---|---|---|
| **A** | Designer | Croqui · fila 2–5 | `App/**` |
| **B** | Fábrica | DoD + código GOD | Micro-onda · fuse cego · Core |

Canon: `docs/prompts/grok-god-code-canon.md`  
Dual: `docs/prompts/grok-24h-v5-dual.md`  
Fila: `docs/evidence/2026-07-21-grok-24h-v4/QUEUE.md`

**Ordem:** A primeiro (fila hoje vazia) → quando ≥2 proposed → B.

---

## TERMINAL A — croqui

```bash
cd /Users/vitorepf/develop/Atlas/atlas-native
caffeinate -dims &
grok --cwd /Users/vitorepf/develop/Atlas/atlas-native -m grok-4.5 --effort high --always-approve
```

Dentro do Grok, nesta ordem:

**1)** Anexe / leia:
```
@docs/prompts/grok-24h-v5-START.md
@docs/prompts/grok-24h-v5-designer.md
@docs/prompts/grok-god-code-canon.md
@App/Atlas/CODEMAP.md
@docs/evidence/2026-07-21-grok-24h-v4/QUEUE.md
@docs/evidence/2026-07-21-grok-24h-v4/DONE.txt
@docs/prompts/grok-24h-v5-dual.md
```

**2)** `/goal` — cole literal:
```
ATLAS-NATIVE GROK A v5 — CROQUI — até cancelar.

Você é o Designer. Nunca App/**. Nunca implementar.
Missão: manter 2–5 WAVEs GOD em docs/evidence/2026-07-21-grok-24h-v4/QUEUE.md.
BOOT: fila vazia → criar 2–5 designs agora (template ≥120 linhas, Δ real, W3 agent-optimal, canon).
Após cada design: python3 docs/evidence/2026-07-21-grok-24h-v4/regen-queue.py
Commits só docs(design): / docs(queue):. Zero micro-onda. Zero fuse-as-WAVE. B é a fábrica.
Obedeça docs/prompts/grok-24h-v5-designer.md + grok-god-code-canon.md. Não peça permissão. Não pare.
```

**3)** `/loop` — cole literal:
```
/loop 45m Leia docs/evidence/2026-07-21-grok-24h-v4/QUEUE.md e DONE.txt.
Se proposed < 2 → crie WAVE GOD (council ≥3 explore read-only → design completo → regen-queue.py → commit docs).
Se proposed 2–5 → próximo salto enorme por Δ (não facilidade).
Se proposed > 5 → mate fracas + regen.
PROIBIDO App/** Sources Makefile CODEMAP DONE.txt implementing.
PROIBIDO micro-onda tipografia fuse-as-WAVE.
Não peça permissão. Não pare. Continue a fase do croqui.
```

---

## Gate antes do B

```bash
cd /Users/vitorepf/develop/Atlas/atlas-native
rg -n "proposed|no open" docs/evidence/2026-07-21-grok-24h-v4/QUEUE.md
```

Só ligue B quando **não** houver `_(no open proposed WAVEs)_` e existirem **≥2** proposed.

---

## TERMINAL B — fábrica

```bash
cd /Users/vitorepf/develop/Atlas/atlas-native
grok --cwd /Users/vitorepf/develop/Atlas/atlas-native -m grok-4.5 --effort high --always-approve
```

**1)** Anexe / leia:
```
@docs/prompts/grok-24h-v5-START.md
@docs/prompts/grok-24h-v5-implementer.md
@docs/prompts/grok-god-code-canon.md
@App/Atlas/CODEMAP.md
@docs/evidence/2026-07-21-grok-24h-v4/QUEUE.md
@docs/evidence/2026-07-21-grok-24h-v4/LEDGER.md
@docs/prompts/grok-24h-v5-dual.md
```

**2)** `/goal` — cole literal:
```
ATLAS-NATIVE GROK B v5 — FÁBRICA — até cancelar.

Você é o Implementer. Execute WAVEs do A + eleva código GOD (métodos nomes estrutura polish ↓LOC intenção) para IA.
Consuma QUEUE rank 1 se passar §WAVE (≥120 linhas design, ≥5 files, DoD≥5). Rejeite micro-onda.
W2+W3 100% → DONE.txt + regen-queue.py + CODEMAP + ledger.
Fila vazia: máx 1–2 IDLE-COMPRESS canônicos (canon §7) — zero micro-WAVE inventada.
Gates todo App commit: swift run AtlasCoreChecks · cd App && make build · ./scripts/grok-god-wave-guard.sh
Casca only. Zero área nova. Zero Core. Obedeça grok-24h-v5-implementer.md + grok-god-code-canon.md.
Não peça permissão. Não pare.
```

**3)** `/loop` — cole literal:
```
/loop 45m Leia docs/evidence/2026-07-21-grok-24h-v4/QUEUE.md e LEDGER.md.
Se active_wave → termine W2/W3.
Senão se proposed forte → §WAVE gate → implemente 100% + W3 GOD + DONE + regen + CODEMAP.
Senão fila vazia → 1 IDLE canônico com ROI (delete/Judgment/rename/MARK/fuse mesmo domínio) — máx 2 sem ROI.
PROIBIDO micro-WAVE tipografia fuse cosmético Shell>600 any>2000 Core Sources.
Não peça permissão. Não pare. Continue a fase ativa da fábrica.
```

---

## Sinais

| Bom | Ruim |
|---|---|
| A `docs(design): WAVE-…` | Fila vazia com A “rodando” |
| B `feat(ui): WAVE-…` | B só IDLE-COMPRESS em loop |
| Guard OK | A tocou App |

**Proibido neste dual:** `--max-turns`, watchdog v3 antigo, prompts v1/v2/v4 sem ponte v5.
