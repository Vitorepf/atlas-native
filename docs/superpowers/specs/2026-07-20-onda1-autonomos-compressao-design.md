# Onda 1 — Autônomos compressão (design)

> Gerado pelo Grok Builder (Fase 1 plan) · implementado no Cursor.
> Contrato: `docs/prompts/grok-atlas-native-full-refactor.md`

# D4. Design Onda 1 — Autônomos (completo)

## Estado atual
Ver D1 §Autônomos. Live path = MapShell v9. ~78% das linhas Autônomos são mortas pós-cutover.

## Alvo mínimo
```
AutonomosView (header limpo)
  └─ AutonomosMapShell
       ├─ List (operatorUnits | empty + Novo)
       ├─ Hub (vivo/parado · Evolução · Pausar/Retomar/Encerrar)
       ├─ Evolution (ausência honesta)
       ├─ stub decisions (até §5)
       └─ ArenaPremiumAskPill → ConversationView(taskKind: autonomos)
Model: OperatorCatalog local; fields loop podem permanecer no model (não reexpor na face)
```

**~20 conceitos de arquivo quente** (não 507). Meta linhas casca Autônomos: **~10.6k → ~2–3k**.

## DELETAR
1. `AutonomosLoadedSection*.swift` (tree completa)
2. `AutonomosFleet*`, `AutonomosDigest*`, `AutonomosOperationDigest*`, `AutonomosAwaiting*`, `AutonomosAreaDetail*`, `AutonomosAreaPicker*`, `AutonomosAreaSection*`, `AutonomosAreaDelivered*`, `AutonomosDetail*`
3. Orphans: `AreaMapView`, `FleetMapView`, `CycleView`, `DecisionsView`, `DecisionView`, `IncidentView`, `DestinationRouter`, `GovernanceSheet`
4. Sheets mortas **após** desligar binds: Transfer/Reason/Control/StartRun/SheetsModifier/Rhythm/Areas/DecisionAction
5. `AutonomosChrome*` (não MapChrome), fleet empties, A11yID frota-only unreferenced
6. Estimativa: **~437 files / ~8.2k lines**

## FUNDIR / REUSAR
- Reusar `ArenaPremiumAskPill`, tokens AtlasTheme/Type/Motion
- Fundir vestment único
- Spoken catalog language (Home + Autonomos)
- Header: sem refresh mentiroso
- Evolution craft: mono/secondary age, não ouro de “prova”

## NÃO TOCAR
- `Sources/**` · `ConversationModel.swift` · `AtlasSession.swift` · `Package.swift` · `App/project.yml` · `App/Makefile`
- Arena/Code/Conversation mass (exceto spoken Home 1 linha)
- Inventar create/persist
- Reintroduzir frota como lista
- Big-bang `App/Atlas/**`

## Commits (ordenados)
1. `polish(ui): Autônomos delete dead LoadedSection/fleet/digest forest`
2. `polish(ui): Autônomos delete orphan maps + dead sheets`
3. `polish(ui): Autônomos honesty chrome (spoken, refresh, evolution gold)`
4. opcional `polish(ui): Autônomos fuse vestment/header peels`
5. `docs(obra): §7 Onda 1 Autônomos compressão` (+ design doc path)

## Riscos + rollback
- Build break por ref residual → delete por família + build incremental; desligar sheet modifiers primeiro
- UITests IDs frota → ajustar se falhar
- Widgets deep link `atlas://autonomos` permanece
- Rollback: `git revert` SHA delete (main local, sem force-push)

## Prova
```bash
swift run AtlasCoreChecks
cd App && make build
make device
```
Device: empty → Novo → hub → Evolução → pílula → backs. Screenshot operador.

## §5 permanece aberto após Onda 1
- POST create + persistência
- Digest schedule
- Wire motor Evolução/Decisões por unit
- Pack Core pílula

## NÃO construir
Framework genérico · 2ª pílula · UserDefaults · dashboard frota “por se” · wire Decisions com backlog global · implementar POST na casca

---

# Critérios de excelência (score da Onda 1)

1. **Menos linhas** — sim, −~8k mortas  
2. **Menos conceitos** — face = lista/hub/evolução/pílula  
3. **Honestidade** — spoken + refresh + evolution gold  
4. **Velocidade** — load já instantâneo; menos símbolos compilados  
5. **Pílula** — mantida, contexto unidade  
6. **Menos bug surface** — zero dual product memory  
7. **Beleza** — craft v9 preservado, presença não manifesto  

---

# HANDOFF — Atlas Native Onda 1

### Superfície
**Autônomos** (casca iOS, `App/Atlas/Autonomos*`)

### Objetivo (1 frase)
Comprimir a casca Autônomos para a face v9 soberana (catálogo → hub → evolução + pílula), **deletando ~8k linhas de floresta frota/dashboard órfã**, sem inventar create e sem tocar Core.

### DELETAR
- `App/Atlas/AutonomosLoadedSection*.swift` — face antiga nunca montada (`AutonomosLoadedSection(` = 0)
- `AutonomosFleet*`, `AutonomosDigest*`, `AutonomosOperationDigest*`, `AutonomosAwaiting*`, `AutonomosAreaDetail*`, `AutonomosAreaPicker*`, `AutonomosAreaSection*`, `AutonomosAreaDelivered*`, `AutonomosDetail*` — só alcançáveis pela árvore morta
- `AutonomosAreaMapView`, `FleetMapView`, `CycleView`, `DecisionsView`, `DecisionView`, `IncidentView`, `DestinationRouter`, `GovernanceSheet` — 0 constructors na face
- Sheets mortas (Transfer/Reason/Control/StartRun/SheetsModifier/Rhythm…) **depois** de remover binds em `AutonomosView`
- `AutonomosChrome*` (≠ MapChrome), empties frota, A11yID frota-only órfãos
- Estimativa: **~437 arquivos / ~8 267 linhas**

### FUNDIR / REUSAR
- Reusar `ArenaPremiumAskPill` + `AutonomosAskContext` + `AutonomosMapChrome`
- Fundir `AutonomosHubVestment` + `HubView.LocalVestment`
- Spoken: `RootHomeSections+Operacao` + a11y Autônomos → linguagem de **catálogo**, não frota
- Header: remover refresh no-op
- Evolution: `ageLabel` sem ouro de prova falsa

### NÃO TOCAR
- `Sources/**` · `ConversationModel.swift` · `AtlasSession.swift` · `Package.swift` · `App/project.yml` · `App/Makefile`
- Lógica de `AutonomosModel` control/decide/transfer (APIs Core) — só UI morta
- Persistência create na casca
- Arena / Código / Conversa (exceto 1 spoken Home)

### §5 pedidos (se houver)
1. **ABERTO** POST criar Autônomo (nome+carta) + persistência — OBRA §5  
2. C19/C20 digest agendado  
3. Pack Core pílula Autônomos (formalizar)  
→ Casca **não** contorna; Evolução/Decisões motor ficam stub honestos

### Passos de implementação (ordenados)
1. Claim/escopo em sessão; `git status` limpo do alheio  
2. Desligar sheet modifiers/openers mortos em `AutonomosView` se necessário  
3. Delete família LoadedSection + Fleet/Digest/Area/Awaiting/Detail  
4. `make build`  
5. Delete orphans mapa + sheets mortas + chrome/a11y órfãos  
6. `swift run AtlasCoreChecks` + `make build`  
7. Honesty: spoken Home/A11y, refresh, evolution gold  
8. Opcional: fuse vestment/header peels  
9. `make device` + tour lista→hub→evolução→pílula  
10. OBRA §7 + commit(s) `polish(ui)` escopados; gravar design doc no path abaixo  

### Prova
- `swift run AtlasCoreChecks`
- `cd App && make build`
- `make device`

### Riscos
- Ref residual quebra build → delete incremental por família  
- UITest IDs frota → ajustar se falhar  
- Não apagar deep link / model APIs usadas por widgets  
- Rollback: revert do commit de delete  

### Design doc path
`/Users/vitorepf/develop/Atlas/atlas-native/docs/superpowers/specs/2026-07-20-onda1-autonomos-compressao-design.md`  
*(conteúdo completo desta seção D4 — gravar no repo ao sair de plan mode / no início de IMPLEMENTAR AGORA; bloqueado em plan mode para paths fora do plan file)*

---
