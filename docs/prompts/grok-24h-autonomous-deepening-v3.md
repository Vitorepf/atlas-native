# MISSÃO 24H v3.1 — GOD WAVES (hardened)

> **Auditoria:** a v3.0 tinha furos (abaixo). Esta v3.1 fecha o que um prompt + ledger +
> guard script conseguem fechar.  
> **Verdade pétrea:** nenhum texto **garante** que o Grok obedeça. O que existe é
> **aumento de pressão** + **checagens mecânicas**. Se o modelo ignorar o ledger/guard,
> ele ainda pode desviar — aí o operador corta.
>
> Cole este arquivo. `/always-approve` · `/effort high` · `/goal` §8 · `/loop` §9.  
> Rode o guard antes de todo commit de produto: `./scripts/grok-god-wave-guard.sh`

---

## A. Furos da v3.0 (já observados / previsíveis) → correção v3.1

| Furo | Por que quebra | Correção |
|---|---|---|
| “Enorme” sem métrica | Modelo redefine leap2/3 como “onda” | §B critérios mínimos objetivos |
| Sem máquina de estados | Pula W0/W1 e codeia | Ledger `phase=` obrigatório; transições únicas |
| `/design` grava em TMPDIR | Design some; implementa sem artefato no repo | Copiar design aprovado → `WAVE-NNN-design.md` **antes** de W2 |
| Subagent write sob plan/always-approve | Implementa “sem querer” no W0/W1 | W0/W1: só `explore` / read-only; **proibido** subagent general-purpose writer |
| `/loop` 45m interrompe onda longa | Empurra micro ou reinicia council no meio do design | Loop só **continua a fase ativa**; nunca “comece leap novo” se `phase≠idle` |
| Escape “micro desbloqueia wave” | Vira fábrica de micro de novo | Micro só com `CANDIDATES` esgotados **e** `waves_completed≥1` **e** justificativa no ledger |
| Sessão ainda em v2 | Continua leaps rápidos (já 6 leaps) | Operador deve re-setar `/goal` v3.1; ledger **v3** novo |
| Compressão sem ΔLOC | W3 vira polish | W3 exige meta ΔLOC e relatório `WAVE-NNN-compress.md` |
| God-file só “proibido” em prosa | Já violou na v1 | Guard script falha se View/Shell >400 |

---

## B. O que É uma GOD WAVE (critérios mínimos — todos)

Uma onda só pode entrar em W1 se o council declarar **e** o ledger copiar:

1. **Patamar:** muda capacidade/experiência de uma superfície **ou** eixo transversal (não copy isolado, não um modifier).
2. **Escopo mínimo (um dos):**
   - toca **≥3 arquivos-host/superfícies distintas** com mudança de comportamento, **ou**
   - DoD com **≥5 bullets** de comportamento observável, **ou**
   - compressão estrutural prevista **≥800 LOC líquidas** na W3 ligada a esta onda
3. **Casca-desbloqueada:** zero campo/API/persistência nova inventada; Core gaps → §5, não “teatrinho”.
4. **Anti-micro:** se o trabalho cabe em **<30 min** e **<5 arquivos**, **não é WAVE** — rejeitar no W0.
5. **Nome:** `WAVE-NNN-<slug>` no ledger + design path.

Exemplos que **passam:** sistema pílula+pack em todas faces ops; grafo soberano casca; Arena Premium+delete morto+honesty; Conversa sink empty/error/offline+glass; Autônomos v9 profundidade.

Exemplos que **falham** o teste de onda: `silenciar→pausar`; “unificar um chrome modifier”; “empty default num campo”; delete de 2 peels mortos.

---

## C. Máquina de estados (única legal)

```
idle → W0_council → W1_design → W2_implement → W3_compress → idle
```

**Proibido:**
- `idle` → W2 (sem design)
- W1 → idle sem `design_approved: true`
- W2 → W0 (abandonar onda no meio)
- Qualquer `feat(ui)` commit sem `active_wave` + `phase=W2_implement|W3_compress`
- Dois `active_wave` ao mesmo tempo

Ledger **sempre** tem:

```yaml
phase: idle|W0_council|W1_design|W2_implement|W3_compress
active_wave: null|WAVE-NNN-slug
design_path: null|docs/evidence/2026-07-21-grok-24h-v3/WAVE-NNN-design.md
design_approved: false|true
```

Cada transição = atualizar ledger **no mesmo commit docs** ou antes do próximo código.

---

## D. Protocolo endurecido

### W0 — Council (pensar enorme)

1. Atualize ledger `phase=W0_council`.
2. Spawne **≥3 subagents em paralelo**, tipos **somente leitura** (`explore` / read-only).  
   **PROIBIDO** nestes subagents: editar `App/**`, `Sources/**`.
3. Cada um devolve candidatos com: Δ patamar · prova (paths) · bloqueios Core · estimativa de LOC W3.
4. Escreva em ledger `## Candidates` ranqueados por Δ patamar (**não** facilidade).
5. Escolha **#1** casca-desbloqueado. Se não passar §B → desça na lista; se nenhum passar → declare bloqueio e **pense de novo** (não micro).
6. Só então `phase=W1_design`.

### W1 — `/design` (obrigatório)

1. `/design <WAVE-NNN: …>` usando a skill design (writer→reviewer até 0 issues críticas).
2. **Copie** o design aprovado para  
   `docs/evidence/2026-07-21-grok-24h-v3/WAVE-NNN-design.md`
3. O doc **deve** conter seções: Problema · Patamar · Arquitetura · Arquivos · DoD (≥5) · Anti-objetivos · Plano W3 (ΔLOC alvo) · Gates.
4. Ledger: `design_path=…`, `design_approved=true`, `phase=W2_implement`.
5. **Zero** edits em `App/Atlas/**` até o arquivo `WAVE-NNN-design.md` existir no git.

### W2 — Implementar 100%

1. Só o que o design lista (ou amend design + re-approve se descobrir gap).
2. Commits: `feat(ui): WAVE-NNN …` (prefixo **obrigatório** `WAVE-NNN`).
3. Gates por pacote: `AtlasCoreChecks` + `make build`.
4. Rode `./scripts/grok-god-wave-guard.sh` antes de commit.
5. DoD do design 100% → então `phase=W3_compress` (não vá a W0).

### W3 — Varredura compressão estrutural

1. Subagents explore: duplicação, peels mortos, paths ruins **no escopo da onda + adjacências**.
2. Refator / defator / fundir / abstrair (2º consumidor) / paths mais simples.
3. Metas: ↓ LOC · ↑ clareza · hosts ≤200 alvo / **hard fail >400** · **não** ↓ contagem de arquivos como objetivo · **não** token opacity.
4. Escreva `WAVE-NNN-compress.md` com ΔLOC medido (`git diff --numstat` da fase).
5. Gates + guard. Ledger: `waves_completed++`, `compress_passes++`, `phase=idle`, `active_wave=null`.
6. Imediato: novo W0 (onda ENORME seguinte).

---

## E. Micro-salto (último recurso — checklist AND)

Só se **todas**:

1. `phase=idle`
2. Último W0 gravou `Candidates` e **nenhum** passa §B (ou todos Core-blocked com §5 escrito)
3. `waves_completed ≥ 1` nesta sessão v3
4. Ledger `micro_resorts` incrementa com justificativa de 3 linhas
5. Commit message `polish(ui): MICRO …` (nunca fingir WAVE-)

Senão: volte a W0.

---

## F. Hard fails (pare e reverta o commit)

- `*View*.swift` / `*Shell*.swift` > **400** linhas
- `collapse` / “into host files” na mensagem ou no efeito
- Edit em `Sources/**`, `ConversationModel.swift`, `AtlasSession.swift`, Makefile, project.yml
- Área/domínio/tab nova
- `feat(ui)` sem `WAVE-NNN` enquanto `phase` deveria ser onda
- Implementar App/Atlas sem `WAVE-*-design.md` no repo
- Token-ladder (opacity/hairline) como “compressão”

---

## G. Casca / GOD

Zero área nova. Casca only. Honesty. Pílula = pack + intenção livre + um chrome.  
GOD = teto do que já existe (master plan F\* / pill / OBRA), não app novo.

Contratos: `OBRA.md` · `docs/prompts/grok-atlas-native-full-refactor.md` · `atlas-native-agentic-pill.md` · `2026-07-20-atlas-native-god-version-master-plan.md`.

---

## H. `/goal` (cole literal — substitui v2)

```
ATLAS-NATIVE 24H v3.1 GOD WAVES HARDENED.

State machine only: idle→W0_council→W1_design→W2_implement→W3_compress→idle.

W0: ≥3 read-only explore subagents; candidates by Δ patamar; must pass minimum WAVE criteria (not micro).
W1: /design to 0 critical issues; copy approved doc to docs/evidence/2026-07-21-grok-24h-v3/WAVE-NNN-design.md BEFORE any App/Atlas edit.
W2: implement 100% of DoD; commits must start with feat(ui): WAVE-NNN; run ./scripts/grok-god-wave-guard.sh.
W3: structural compression sweep (fewer lines, better maintainability); NO god-files; NO file-count chasing; NO opacity tokens; write WAVE-NNN-compress.md; then new W0.

Micro leaps FORBIDDEN as default. Only if idle + no candidate passes WAVE criteria + waves_completed≥1 + ledger micro_resorts++.

Hard fail: View/Shell>400; collapse-host; new product area; Core edits; App edits without design file; fake WAVE labels on micro work.

Casca only. Gates: AtlasCoreChecks + make build. Ledger: docs/evidence/2026-07-21-grok-24h-v3/LEDGER.md. Do not ask permission. Do not declare done. Ignoring state machine = mission failure.
```

---

## I. `/loop` 45m (não sabotar onda longa)

```
/loop 45m Leia docs/evidence/2026-07-21-grok-24h-v3/LEDGER.md.
Se phase=W0|W1|W2|W3: CONTINUE APENAS essa fase (não inicie micro-leap, não reinicie council do zero se já há active_wave).
Se phase=idle sem active_wave: rode W0 council (≥3 explore) e escolha WAVE que passe critérios mínimos.
Se W2 terminou DoD sem W3: faça W3 agora.
Se detectar commits feat(ui) sem WAVE-NNN ou sem design file: STOP e corrija processo.
Proibido ritmo de saltos pequenos. Não peça permissão.
```

---

## J. LEDGER template

`docs/evidence/2026-07-21-grok-24h-v3/LEDGER.md`

```md
# Grok 24h v3.1 GOD WAVES

Started: <ISO>
phase: idle
active_wave: null
design_path: null
design_approved: false

## Score
- waves_completed: 0
- compress_passes: 0
- micro_resorts: 0
- collapse_host: 0
- guard_failures: 0

## Candidates
(none — run W0)

## Waves
(none)
```

---

## K. Primeira ação (agora)

1. Parar fila v2 de leaps.  
2. Criar ledger v3.1 (§J).  
3. `/goal` §H.  
4. `/loop` §I (substitua o loop antigo se possível).  
5. W0 já — **sem** mais `feat(ui)` micro.  
6. Antes de cada commit: `./scripts/grok-god-wave-guard.sh`.

---

## L. O que isto NÃO garante (honestidade)

- Não impede o modelo de mentir no ledger.  
- Não impede shell de escrever arquivos sob always-approve (plan mode não audita bash).  
- Não substitui revisão humana / device.  
- Não desbloqueia Core (§5).  
- “Versão Deus” completa em 24h é **ambição**, não contrato fechado.

O que **aumenta** a chance: estado explícito + critérios §B + design no repo + guard + loop que não reinicia onda + ban de micro como ritmo.
