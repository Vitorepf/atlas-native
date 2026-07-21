# WAVE-174 — timeline-narrative-filter-markdown-pack-wire

**Status:** design · proposed · high
**Wave:** WAVE-174-timeline-narrative-filter-markdown-pack-wire
**Owner:** casca only · residual full-bar
**Date:** 2026-07-21
**Created by:** implementer residual pack campaign
**Δ patamar:** **high**

## Problema
`LiveTimelineNarrativeJudgment`, `LiveTimelineFilterJudgment` e `AtlasMarkdownJudgment`
têm `packFacts` hollow (zero caller externo). A pílula mid-thread já vê steps
grossos em `ExecutionProofJudgment`, mas **não** a face de narrativa/filtro nem
os kinds de bloco markdown do texto do turno. WAVE-170 deferiu Timeline por
“sem ask host” — o host correto já existe: `ConversationOccasionPack` +
`presenceBubble.activities` / `bubble.text`. Filtro UI é `@State` local; pack
usa recorte **aberto** (`.all`) com absence honesta.

## Patamar
| Antes | Depois |
|---|---|
| proof `steps: N` só | narrative face + filter open + intents |
| editorial meta only | md_block_kinds list\|quote\|code do texto |
| hollow packFacts 3 organs | wired mid-thread ask |

Δ = honesty da orquestra viva + markdown estruturado no pack da pílula.

## Arquitetura
Casca only · zero Core · zero Search pill · zero Rhythm invent.

### Dados
- `bubble.activities` → `narrativeRows(from:)` (já casca) → narrative/filter pack
- `bubble.text` → `AtlasMarkdown.parse` → kinds → `AtlasMarkdownJudgment.packFacts`
- Filter pack: `filter=.all`, `isActive=false` + absence “filtro de leitura é local à UI”

### Arquivos (≥5)
1. `ConversationOccasionPackLive.swift` — wire timeline organs
2. `ConversationOccasionPackOrgans.swift` — wire markdown no proof/editorial organ
3. `LiveTimelineNarrativeJudgment.swift` — convenience `packFacts(from activities:)`
4. `AtlasMarkdownJudgment.swift` — convenience `packFacts(from text:)`
5. `CODEMAP.md` + design + compress + DONE + LEDGER

### Densidade
wire + thin convenience (agent-optimal hosts)

### Fora de escopo
- Core / Sources / ConversationModel lógica
- SearchScreen pack (ainda sem pill host — não inventar)
- AutonomosRhythm (janelas async — absence já em Veto organ)
- Density peels cosméticos · tipografia
- Inventar TimelineAskContext / SearchAskContext

### §5
nenhum

## DoD produto (≥5)
- [ ] `LiveTimelineNarrativeJudgment.packFacts` mid-thread com activities
- [ ] `LiveTimelineFilterJudgment.packFacts` open + absence UI-local
- [ ] `AtlasMarkdownJudgment.packFacts` do texto do presence bubble
- [ ] Convenience APIs sem mentir filtro ephemeral
- [ ] Gates: AtlasCoreChecks · make build · grok-god-wave-guard
- [ ] CODEMAP + DONE + compress + LEDGER
- [ ] DEVICE_PENDING (passcode)

## Anti-objetivos
- micro-WAVE rename-only
- inventar Search pill / Timeline tab
- reordenar narrativa (chrono sagrado)
- inventar filter UI state no pack
- Core / área nova

## Plano W3 GOD
1. Convenience narrative/markdown pack from domain inputs
2. Wire Live organs (timeline) + Organs (markdown next to editorial)
3. Gates verdes
4. CODEMAP “Onde muda X” · DONE · compress · regen · LEDGER truth

## Proof
1. bubble sem activities → timeline empty/absence
2. bubble com N activities → `timeline_face: live` + `base_steps: N`
3. filter pack always open + absence UI-local
4. texto com ``` / lista → `md_block_kinds`
5. texto plain → absence estruturado ou kinds vazios honestos
6. DEVICE_PENDING

## Council
Últimos hollows com host Conversation real. Search/Rhythm continuam host-blocked.
Não inventar micro-onda de density — peels 171–173 já fecharam fails densos.

### Why full-bar
≥5 files · design ≥120 linhas · DoD≥5 · muda patamar pack honesty · não cabe em fuse idle

### Rejection
Search invent · Rhythm invent · density-only → fail §WAVE

### Related
WAVE-170 defer Timeline · WAVE-165 proof/editorial · WAVE-044/075 timeline faces

### Sequence after
A fill · Search only com product host · Rhythm se windows síncronas no pack

### Acceptance
Build green · GUARD OK · DEVICE_PENDING

### W2/W3
Wire 100% · CODEMAP · DONE · compress · regen-queue · LEDGER rewrite if wipe

---

## Appendix — pack shape (expected)

```
facts:
- timeline_face: live|empty|…
- filter: all
- base_steps: N
- timeline_filter_face: open
- md_block_kinds: list|code
absences:
- filtro de leitura da timeline é local à UI — pack usa recorte aberto
- (opcional) nenhum bloco estruturado no markdown deste recorte
```

## Appendix — non-goals detail

Não tocar `LiveTimeline` `@State filter`. Não serializar chip selection.
Não parsear markdown no Core. Convenience no Judgment casca only.

## Appendix — risk

`narrativeRows(from:)` + duration annotate é presentation-safe (já na casca).
Parse markdown pode ser O(text) no pack — aceitável; presence bubble text
já renderiza na UI.

## Appendix — test matrix

| case | expect |
|---|---|
| no published | organs skip / live absences |
| activities empty | narrative empty absence |
| activities 3 | live + base_steps 3 |
| md plain | no kinds or absence |
| md fence | code kind |
| gates | green |

## Appendix — commit message

`feat(ui): WAVE-174 timeline narrative filter markdown pack wire`

## Appendix — implementer notes

Casca only. Zero permissão. W2+W3 atômico se possível.
LEDGER concurrent: reescrever truth após regen se wipe.
IDLE max 2 already consumed post-173 stubs + historical — this is residual full-bar.

## Appendix — density check

No shell >600. Judgment convenience +20 LOC max each.
Hosts Live/Organs stay agent-optimal.

## Appendix — god rename

No rename required. Existing `packFacts` sovereignty.

## Appendix — a11y

Unchanged. Spoken path already uses Judgments.

## Appendix — dual A

A may propose Search host later; B does not invent.
