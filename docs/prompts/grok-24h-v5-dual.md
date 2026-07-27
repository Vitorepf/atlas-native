# ATLAS-NATIVE — Dual Grok v5 (A croqui · B fábrica)

> Dois processos. Duas fronteiras. Um ledger.  
> **A** = cérebro / croqui (planeja implementações enormes).  
> **B** = fábrica (executa WAVEs + eleva código GOD para IA).  
> Lei de código: `docs/prompts/grok-god-code-canon.md`  
> **Arranque:** `docs/prompts/grok-24h-v5-START.md` ← leia primeiro

| Papel | Prompt | Edita |
|---|---|---|
| **A · DESIGNER** | `docs/prompts/grok-24h-v5-designer.md` | só `docs/evidence/2026-07-21-grok-24h-v4/**` (+ ler App) |
| **B · IMPLEMENTER** | `docs/prompts/grok-24h-v5-implementer.md` | `App/**` casca + evidence v4 + `CODEMAP.md` |

Fila/ledger (path estável):

- `docs/evidence/2026-07-21-grok-24h-v4/QUEUE.md`
- `docs/evidence/2026-07-21-grok-24h-v4/LEDGER.md`
- `docs/evidence/2026-07-21-grok-24h-v4/WAVE-*-design.md`
- Guard: `./scripts/grok-god-wave-guard.sh`

---

## Modelo mental

1. **A** planeja / rankeia / croqui. Nunca `App/**`. Mantém **2–5** WAVEs GOD na fila.  
2. **B** é a fábrica: implementa DoD + eleva código (rename, delete, Judgment, polish, ↓LOC intenção).  
3. Fila vazia = **falha de A** (alavancagem) e risco de B idle eterno.  
4. Micro-onda / fuse-as-WAVE = **rejeitada** por A e B.  
5. Densidade = canon (Shell ≤600; any ≤2000; um domínio/arquivo).

---

## Anti-colisão (pétrea)

1. Só B edita `App/**`.  
2. A falha se tocar App/Sources/Makefile/project.yml/CODEMAP.  
3. Um `active_wave` por vez (B).  
4. Commits:  
   - A: `docs(design):` / `docs(queue):`  
   - B: `feat(ui): WAVE-…` / `polish(ui): IDLE-COMPRESS …`  
5. `main` local. Stage explícito. Sem `git add -A`.  
6. Conflito em App → B vence; A só docs.

---

## WAVE mínima

1. Muda patamar (operador)  
2. DoD ≥5 **ou** ≥3 superfícies **ou** W3 ≥300 LOC estrutural real  
3. Casca-desbloqueada  
4. Design ≥**120** linhas (template A v5 completo)  
5. Não cabe em &lt;30 min / &lt;5 arquivos  

B pode auto-approve rank ≤2 que passe isto (operador dormindo).

---

## Idle (B) — resumo

Canon §7: delete morto → extract Judgment → rename → MARK → fuse mesmo domínio → dedupe.  

Proibido: fuse cosmético, multi-domínio, &gt;2000, View/Shell &gt;600, token craft, Core.

---

## Ligar

### Terminal A — DESIGNER (croqui)

```bash
cd /Users/vitorepf/develop/Atlas/atlas-native
caffeinate -dims &
# @docs/prompts/grok-24h-v5-START.md
# @docs/prompts/grok-24h-v5-designer.md
# @docs/prompts/grok-god-code-canon.md
# @App/Atlas/CODEMAP.md
# @docs/evidence/2026-07-21-grok-24h-v4/QUEUE.md
```

`GROK A v5 · croqui · fila GOD 2–5 · zero App · nunca micro-onda`

**Se QUEUE vazia: A liga primeiro e enche 2–5 antes de B fabricar.**

### Terminal B — IMPLEMENTER (fábrica)

```bash
cd /Users/vitorepf/develop/Atlas/atlas-native
caffeinate -dims &
# @docs/prompts/grok-24h-v5-START.md
# @docs/prompts/grok-24h-v5-implementer.md
# @docs/prompts/grok-god-code-canon.md
# @App/Atlas/CODEMAP.md
```

`GROK B v5 · fábrica · consuma QUEUE · idle só canônico · rejeite micro-onda`

Migração:  
A: `MIGRE para Grok A v5; croqui; fila 2–5; zero App.`  
B: `MIGRE para Grok B v5; fábrica; canon; pare fuse factory.`
