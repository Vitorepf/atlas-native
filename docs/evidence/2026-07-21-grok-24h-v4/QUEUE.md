# Atlas Native — GOD WAVES v4 QUEUE

## Policy
- Designer adds `proposed`
- Implementer sets `approved`→`implementing`→`done` (auto-approve rank≤2 if criteria pass)
- Only one `implementing` at a time
- Rank by **Δ patamar**, not ease
- Designer never stages `App/**` or `Sources/**`
- When marking a wave **done**, **re-rank remaining open** designs by Δ — never drop higher-Δ proposed entries that still have design files

## Active
- implementing: null

## Queue (open · ranked by Δ · contiguous ranks 1…N)

```yaml
id: WAVE-012-conversation-run-aftermath-instrument
status: proposed
rank: 1
delta_patamar: max
design: docs/evidence/2026-07-21-grok-24h-v4/WAVE-012-design.md
created_by: designer
approved_at: null
note: "Proof+StateCard+Timeline judgment organ after WAVE-006 live. Explicit 006 residual."
```

```yaml
id: WAVE-013-artifact-change-review-instrument
status: proposed
rank: 2
delta_patamar: high
design: docs/evidence/2026-07-21-grok-24h-v4/WAVE-013-design.md
created_by: designer
approved_at: null
note: "Human veto/accept on agent output — Artifact+ChangeReview instrument."
```

```yaml
id: WAVE-014-plan-timeline-cockpit-instrument
status: proposed
rank: 3
delta_patamar: high
design: docs/evidence/2026-07-21-grok-24h-v4/WAVE-014-design.md
created_by: designer
approved_at: null
note: "Plan roteiro + timeline narrative cockpit; silence when no plan."
```

```yaml
id: WAVE-011-radar-fleet-glance
status: proposed
rank: 4
delta_patamar: med-high
design: docs/evidence/2026-07-21-grok-24h-v4/WAVE-011-design.md
created_by: designer
approved_at: null
note: "Radar 5s multi-repo judgment; mute honesty; severe first."
```

```yaml
id: WAVE-010-arena-suitesheet-instrument
status: proposed
rank: 5
delta_patamar: med+
design: docs/evidence/2026-07-21-grok-24h-v4/WAVE-010-design.md
created_by: designer
approved_at: null
note: "SuiteSheet ~18→5–7 like WAVE-004 RunSheet."
```

```yaml
id: WAVE-015-home-intention-port
status: proposed
rank: 6
delta_patamar: med+
design: docs/evidence/2026-07-21-grok-24h-v4/WAVE-015-design.md
created_by: designer
approved_at: null
note: "Home pill free-first + Home-local pack deepen; workspace secondary."
```

## Candidates ranked (open only · Δ order)

| Rank | id | Δ | design | note |
|---|---|---|---|---|
| **1** | WAVE-012 conversation-run-aftermath | **max** | WAVE-012-design.md | after 006 live |
| **2** | WAVE-013 artifact-change-review | **high** | WAVE-013-design.md | human veto |
| **3** | WAVE-014 plan-timeline-cockpit | **high** | WAVE-014-design.md | continuous roteiro |
| **4** | WAVE-011 radar-fleet-glance | **med–high** | WAVE-011-design.md | multi-repo 5s |
| **5** | WAVE-010 arena-suitesheet | **med+** | WAVE-010-design.md | Arena fog |
| **6** | WAVE-015 home-intention-port | **med+** | WAVE-015-design.md | free-first pill |

### Blocked / Core (not open)

| id | why |
|---|---|
| continuity-presence-restore | App Group off |
| codigo-mandar-cura | Core tool_permissions |

### Rejected
- Island peel micro · redo 001–009 · new area/tab · opacity ladder

## History
- WAVE-001..004 v3.1 done
- WAVE-005 pill machine done-in-tree
- **WAVE-006** done `528a4c1a`
- **WAVE-007** done `b012de30`
- **WAVE-008** done `15cd21cd`
- **WAVE-009** codigo-depth done `e47b5ddd`
- Open designs 010–015 restored to Δ-ranked queue (designer) after implementer prunes
