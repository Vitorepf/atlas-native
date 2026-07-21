# GOD RESTRUCTURE — DEBTS (fila mecânica · 24h)

> Cursor de trabalho. Grok **sempre** tem próximo foco aqui.  
> Não inventar WAVE/produto. Não parar porque “passou o checklist duro”.

## State

```yaml
pass: 1
domain_index: 0
last_focus: "Home RootHomeSections* → RootHomeBody fuse"
passes_completed: 0
```

## Domínios (rodízio obrigatório)

Atacar **um domínio por ciclo** na ordem. Ao terminar o #7, `pass += 1` e volta ao #0 (aprofundar).

| # | Domínio | Glob / âncora |
|---|---|---|
| 0 | Home / Root | `Root*`, `Home*`, `Workspace*` |
| 1 | Conversa | `Conversation*` |
| 2 | Código / Radar | `AtlasCode*`, `*Radar*` |
| 3 | Pílula | `Agentic*` |
| 4 | Arena | `Arena*`, `ArenaPremium*` |
| 5 | Autônomos | `Autonomos*` |
| 6 | Continuity / Widgets | Island / Lock / `Live*` / `App/Widgets/**` |
| 7 | Cross-cut | CODEMAP · `spoken*` · `packFacts` · Theme chrome compartilhado |

## Checklist domain 0 Home (pass 1)

| # | Item | Status |
|---|---|---|
| 1 | Delete morto | open — soft scan next |
| 2 | Rename honesty Sections/States | **done** RootHome* · **open** WorkspaceEmptyStates |
| 3 | Unificar spoken/packFacts/rank | open |
| 4 | MARK >200 LOC | partial (RootHomeBody MARK · RootChrome 355) |
| 5 | Fuse peels <120 same host | **done** RootHome 3→1 |
| 6 | CODEMAP Type.method | partial — Home entry updated |

**Próximo foco:** `WorkspaceEmptyStates.swift` → rename honesty (`WorkspaceEmptyChrome` / Body).

## Soft global (sempre actionable)

```
# rode e cole no LEDGER
find App/Atlas App/Widgets -name '*Sections*.swift' -o -name '*States*.swift'
rg -n 'func (spoken|label|title|copy)' App/Atlas --glob '*Judgment*.swift' | head -40
rg -n 'WAVE-[0-9]' App/Atlas/CODEMAP.md || true
```

Home still has: `WorkspaceEmptyStates.swift`  
Other domains: ConversationEmptyStates, Arena*States, ChangeReviewSections*, etc.

## Proibido

- WAVE produto · dual · Core · Sources · inventar feature  
- Parar / Goal Done / god_hold enquanto o operador não cancelar  
- Pular domínio sem prova  
