# MISSÃO 24H v2 — Leap-first · depois comprimir (Atlas Native)

> **Versão 2 — corrige a falha da noite 2026-07-20/21.**  
> Aquela sessão fundiu peels em **god files** (Conversa 10k LOC) e depois girou
> token gold (`opacity 0.62`). Isso é **proibido** aqui.  
>  
> Cole este arquivo inteiro no Grok. Depois: `/always-approve` · `/effort high` ·
> `/goal` (§G) · `/loop` (§F).  
>  
> **Verdade:** ninguém garante 24h sem falha. Este contrato **impede o modo que
> já falhou** e força a ordem certa: **saltar → só então comprimir**.

---

## 0. Lição da noite anterior (leia e obedeça)

| Fez (errado) | Faça (certo) |
|---|---|
| Fuse peel forests sem julgamento | Só fundir peels **mortos/redundantes** após um salto |
| Collapse hosts em monólitos | Host orquestra ≤200–400; peels por feature 50–150 |
| Residual craft (ink 0.58→0.62) | Proibido até existirem **3 saltos de produto** no ledger |
| CYCLE.md a cada micro-opacidade | 1 CYCLE só por salto ou compressão **mensurável** |
| Contar arquivos Swift como vitória | Vitória = produto melhor **e** arquivos na faixa saudável |

**Se você estiver prestes a colar 5+ peels num único `*View.swift` >400 linhas → PARE. Split ou desista do fuse.**

---

## A. Identidade

Repo: `/Users/vitorepf/develop/Atlas/atlas-native`  
Papel: **CASCA** (Fable). Não Codex. Não área nova.

Produto: iOS de **programação agêntica**. Operador dirige; Atlas executa.
Superfícies essenciais já existem — **aprofundar**, não expandir.

---

## B. Leis pétreas

### B1 — Zero áreas novas
Só: Home · Conversa · Código/Grafo · Arena Premium · Autônomos v9 · Continuity já existente.

### B2 — Ordem obrigatória do trabalho (nunca inverter)

```
FASE LEAP (obrigatória, prioritária)
  → encontrar o maior salto de produto/UX/honesty/capacidade na casca
  → design curto → implementar → gates → commit → ledger

FASE COMPRESS (só depois de ≥1 leap no ciclo atual, ou se LEAP estiver bloqueado por §5)
  → delete morto com prova rg
  → fundir peels redundantes MANTENDO faixa de tamanho
  → defatorar / reusar Theme
  → gates → commit → ledger

FASE TOKEN (opacity, hairline 0.xx, PressableScale sweep)
  → PROIBIDA até o ledger listar 3 leaps de produto nesta sessão
```

### B3 — Orçamento de arquivo (hard fail)

| Tipo | Máximo | Ação se estourar |
|---|---|---|
| `*View*.swift` / shell de superfície | **400 linhas** | split antes de qualquer outro trabalho |
| Peel `+Feature.swift` | **150 linhas** (ideal 50–120) | ok; se <15 e sem 2º consumidor → fundir no vizinho **sem** criar monólito |
| Host orquestra | **200 linhas** preferível | só wiring + composição |

**PROIBIDO ABSOLUTO:**
- `collapse … into host files`
- “fundir tudo da superfície X num arquivo”
- qualquer commit que **aumente** um host já >400
- apagar peels só para reduzir *contagem de arquivos*

Contar Swift files ↓ **não** é métrica de sucesso.  
Métricas: saltos no ledger · ΔLOC com hosts saudáveis · honesty · pílula · delete morto.

### B4 — Casca only
Nunca: `Sources/**`, `ConversationModel.swift`, `AtlasSession.swift`, Makefile, project.yml.  
Falta contrato → `OBRA.md` §5 e **pule** para próximo leap casca.

### B5 — Vocabulário / honesty
- `silenciar` (ação de mute) → **`pausar`** (alinha a “propostas em pausa”)
- Silêncio = estado saudável, não verbo de botão
- Zero número inventado; zero botão falso

---

## C. Contratos (ler na ordem)

1. `OBRA.md` (fronteiras, §3 anti-inchaço, §5, §7)
2. `docs/prompts/grok-atlas-native-full-refactor.md`
3. `docs/engineering-knowledge-base/atlas-native-agentic-pill.md`
4. `docs/superpowers/specs/2026-07-20-atlas-native-god-version-master-plan.md`
5. Ledger: `docs/evidence/2026-07-21-grok-24h-v2/LEDGER.md` (criar)

---

## D. Ciclo eterno (leap-first)

### D0 — GUARD (toda vez, 30s)

```bash
# Se algum *View*/Shell >400 linhas → próximo trabalho = SPLIT, não leap novo nem fuse.
find App/Atlas -name '*.swift' -print0 | xargs -0 wc -l | sort -n | tail -20
```

Se guard falhar → ciclo = **split saudável** (orquestra + peels por feature). Commit. Só então leap.

### D1 — SENSING (leap)

Qual o **maior salto de produto** agora nas superfícies existentes?

Fila preferencial (casca desbloqueada):

1. **Honesty copy** — `silenciar`→`pausar`; status grafo honesto; zero overclaim
2. **Pílula** — um chrome (`atlasGlassCapsule` craft Home); packs presentation-only; intenção livre
3. **Delete morto** — dual-stack / call sites 0 (prova `rg`) — sem colapsar hosts vivos
4. **Grafo soberano (casca)** — glance 5s, a11y, dim/âncora já existentes melhorados
5. **Arena instrumento** — face Premium; sem teatrinho NL se Core não permite
6. **Autônomos v9** — honesty + pílula; create só via §5
7. **Empty/error/offline** como feature
8. **Continuity** só consertar o que já existe (casca-puro)

Se o maior salto for Core → escreva §5 claro e pegue o 2º.

### D2 — PLANO curto
Um arquivo `CYCLE-NNN.md` **só se for leap ou compressão ≥50 LOC líquidas ou split de god-file**.  
Micro-token → **sem** CYCLE.

### D3 — IMPLEMENTAR
Uma vertical. `git add -- <arquivos>`. Prefixo `feat(ui)|polish(ui)|fix(ui)`. Branch `main` local.

### D4 — GATES
```bash
swift run AtlasCoreChecks   # verde
cd App && make build        # verde
```
Vermelho → consertar. Não commit quebrado.  
`make device` = device-pending no ledger (humano dormindo).

### D5 — COMMIT + LEDGER
Atualize LEDGER: leap? compress? split? linhas dos hosts top5.  
`/compact keep: LEDGER, open §5, next leap, file-budget`

### D6 — PRÓXIMO
Imediato. Não declare done. Não peça permissão.

**Compressão** só entra se:
- houve ≥1 leap desde o último compress **ou**
- leap bloqueado por §5/device **e** existe delete/fuse **dentro do orçamento B3**

---

## E. Anti-parada

| Falha | Ação |
|---|---|
| Host >400 | Split agora (D0) |
| Tentação collapse-host | Recusar; fundir só peels mortos |
| Tentação opacity ladder | Recusar até 3 leaps no ledger |
| Build red | Consertar |
| Core preciso | §5 + próximo leap |
| Contexto cheio | `/compact` + LEDGER; não `/new` |
| Sessão morreu | resume + LEDGER |

---

## F. Harness

```
/always-approve
/effort high
/goal <§G>
/loop 45m Leia docs/evidence/2026-07-21-grok-24h-v2/LEDGER.md. Rode D0 (wc -l hosts). Se host>400 → split. Senão CONTINUE leap-first D1→D6. PROIBIDO collapse-host e residual token craft. Não peça permissão. Não pare. Zero área nova.
```

---

## G. `/goal` (cole literal)

```
ATLAS-NATIVE 24H v2 LEAP-FIRST — até cancelar ou 24h.

ORDEM: (1) saltos de produto nas superfícies existentes (2) só então comprimir/deletar/fundir DENTRO do orçamento (3) token craft PROIBIDO até 3 leaps no ledger.

HARD FAIL: nenhum *View*/Shell >400 linhas; proibido “collapse into host”; proibido fundir floresta inteira num monólito. Host orquestra ~200; peel feature 50–150.

Só Home/Conversa/Código/Arena Premium/Autônomos v9/Continuity existente. Casca only. Gates: AtlasCoreChecks + make build. Commit feat(ui)|polish(ui). Ledger em docs/evidence/2026-07-21-grok-24h-v2/. Silenciar→pausar. Não declare done. Não peça permissão. Parar=falha. Collapse-host=falha crítica desta missão.
```

---

## H. LEDGER mínimo

`docs/evidence/2026-07-21-grok-24h-v2/LEDGER.md`

```md
# Grok 24h v2 Ledger — leap-first

Started: <ISO>
Constraint: leap-first; no god-files; no token-craft until 3 leaps; no new areas; casca only

## Score
- leaps_completed: 0
- compress_cycles: 0
- splits_for_budget: 0
- last_commit:
- last_gates:
- top_hosts_wc: (cole saída D0)
- next: LEAP — …

## Leaps log
(none yet)

## Forbidden check
- collapse-host commits: 0 (must stay 0)
```

---

## I. Primeira ação

1. Criar ledger v2 (§H).  
2. Rodar D0. Se hosts >400 (estado legado da noite v1) → **só split** até entrar no orçamento; isso conta como `splits_for_budget`, não como leap.  
3. Depois: leap #1 (`pausar` ou pílula chrome — o maior).  
4. Não esperar operador.

---

## J. Reset recomendado (operador, antes de ligar)

Se a working tree ainda tem god files da v1, **volte ao commit pré-missão** antes de começar:

```bash
cd /Users/vitorepf/develop/Atlas/atlas-native
git status
git reset --hard 7ac8326e   # último commit ANTES da missão 24h v1
# só com OK explícito do operador — isto descarta a noite v1
```

Sem reset, a primeira hora da v2 será só **desfazer monólitos** (correto, mas atrasa leaps).
