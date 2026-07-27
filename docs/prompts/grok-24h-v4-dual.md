# ATLAS-NATIVE 24H v4 — Dual Grok (Designer + Implementer)

> **SUPERSEDED.** Dual completo em **v5**:  
> [`grok-24h-v5-dual.md`](./grok-24h-v5-dual.md) · A [`grok-24h-v5-designer.md`](./grok-24h-v5-designer.md) · B [`grok-24h-v5-implementer.md`](./grok-24h-v5-implementer.md) · [`grok-god-code-canon.md`](./grok-god-code-canon.md)  
> Fila/ledger path v4 permanece.

> **Dois processos Grok. Duas fronteiras. Um ledger.**  
> Isto substitui a intenção da v3.1 single-agent como modo preferido.
>
> | Papel | Processo | Pode editar |
> |---|---|---|
> | **DESIGNER** | só propostas | `docs/evidence/2026-07-21-grok-24h-v4/**` (+ ler App) |
> | **IMPLEMENTER** | **→ v5** W2/W3 + idle canônico GOD | `App/**` casca + ledger v4 + designs |
>
> Artefatos:
> - Prompt Designer: `docs/prompts/grok-24h-v4-designer.md`
> - Prompt Implementer: `docs/prompts/grok-24h-v5-implementer.md` (v4 redireciona)
> - Canon código: `docs/prompts/grok-god-code-canon.md`
> - Fila: `docs/evidence/2026-07-21-grok-24h-v4/QUEUE.md`
> - Ledger: `docs/evidence/2026-07-21-grok-24h-v4/LEDGER.md`
> - Designs: `docs/evidence/2026-07-21-grok-24h-v4/WAVE-NNN-design.md`
> - Guard: `./scripts/grok-god-wave-guard.sh` (Implementer; paths v4 abaixo)

---

## Modelo mental (o que o operador pediu)

1. **Designer** só pensa / `/design` / ranking. **Nunca** implementa.
2. **Implementer** (o que já está na v3):
   - Se há WAVE `approved` na fila → implementa 100% → W3 compress → marca `done`
   - Se a fila está vazia → **não para**: idle compress estrutural (refator/defator/fundir/↓LOC, sem god-file, sem área nova)
   - Também **pode** criar + implementar uma WAVE própria se a fila do Designer estiver seca **e** o idle compress não tiver ROI — mas prefere consumir a fila do Designer

---

## Regras anti-colisão (pétreas)

1. **Só o Implementer edita `App/**`.**  
2. Designer **fail** se tocar `App/**`, `Sources/**`, Makefile, project.yml.  
3. Um `active_wave` de implementação por vez (ledger `implementer_phase`).  
4. Designer nunca muda `status: approved → implementing` (só Implementer).  
5. Commits:
   - Designer: `docs(design): WAVE-NNN …` / `docs(queue): …`
   - Implementer: `feat(ui): WAVE-NNN …` / `polish(ui): IDLE-COMPRESS …`
6. Branch: `main` local. Stage explícito. Sem `git add -A`.  
7. Se conflito de arquivo: Implementer vence em `App/`; Designer rebase/reaplica só docs.

---

## Status da fila (QUEUE.md)

Cada WAVE:

```yaml
id: WAVE-004-arena-…
status: proposed|approved|implementing|done|rejected
rank: 1
delta_patamar: high|med|low
design: docs/evidence/2026-07-21-grok-24h-v4/WAVE-004-design.md
created_by: designer|implementer
approved_at: null|ISO
```

- Designer cria com `proposed`.  
- Operador **ou** Implementer (se política auto-approve estiver on) promove a `approved`.  
- Default v4: **Implementer pode auto-approve** candidatos `rank≤2` que passem critérios mínimos §B (operador dormindo).  
- `rejected` = não passa §B ou Core-only sem casca.

---

## Critérios mínimos de WAVE (iguais v3.1, endurecidos)

Passa se:

1. Muda patamar (não copy/fonte isolada)  
2. DoD ≥5 **ou** ≥3 superfícies **ou** W3≥300 LOC estimado  
3. Casca-desbloqueada  
4. Design ≥80 linhas com Arquitetura + DoD + Anti-objetivos + Plano W3  
5. Não cabe em &lt;30 min / &lt;5 arquivos  

---

## Idle compress (Implementer, fila vazia)

Permitido:

- Fundir peels redundantes da **mesma feature** (50–150 LOC peels; hosts ≤400 hard)  
- Delete morto com prova `rg` = 0 call sites  
- Defatorar duplicação Theme/chrome  
- Honesty copy residual ligado a superfície já viva  

Proibido no idle:

- Nova área / nova WAVE fingida sem design  
- Collapse host  
- Token opacity ladder como “compressão”  
- Tocar Core  

Idle commits: `polish(ui): IDLE-COMPRESS …` + nota no ledger `idle_compress_passes++`.

---

## Opinião / quando usar

**Bom:** Designer enche a fila de ondas grandes enquanto Implementer não fica ocioso.  
**Ruim se:** os dois implementam, ou Designer “ajuda” no App.  
**v4 > v3** só com essa fronteira. Sem ela, é pior que um Grok só.

---

## Como ligar (dois terminais)

### Terminal A — DESIGNER

```bash
cd /Users/vitorepf/develop/Atlas/atlas-native
caffeinate -dims &
grok --always-approve --effort high
```

Dentro: `@docs/prompts/grok-24h-v4-designer.md` + `/goal` do arquivo Designer + `/loop` Designer.

### Terminal B — IMPLEMENTER

```bash
cd /Users/vitorepf/develop/Atlas/atlas-native
grok --always-approve --effort high
```

Dentro: `@docs/prompts/grok-24h-v4-implementer.md` + `/goal` Implementer + `/loop` Implementer.

Se já existe sessão v3: cole o prompt Implementer e diga `MIGRE para v4 implementer; consuma QUEUE v4; idle-compress se vazia`.
