# WAVE-004 — compress report

**Wave:** `WAVE-004-arena-runsheet-instrument`  
**Commit:** `e80fa6cf` (implement + structural fuse same package — design primary deliverable is fuse)

## ΔLOC (measured)

```
git show --numstat --format= e80fa6cf | awk '{a+=$1;d+=$2} END {print a,d,a-d}'
```

| | lines |
|---|---|
| **added** | 541 |
| **deleted** | 841 |
| **net** | **−300** (commit message: +541/−841; cached pre-commit numstat was −386 on App only) |

Product files only (ArenaRunSheet*): **48 peels → 5 files**; LOC **~867 → 481** (**−386** on that tower).

## Fuse map (done)

| After | LOC |
|---|---:|
| `ArenaRunSheet.swift` | 167 |
| `ArenaRunSheet+Form.swift` | 128 |
| `ArenaRunSheet+Spoken.swift` | 92 |
| `ArenaRunSheet+Toggle.swift` | 51 |
| `ArenaRunSheet+Receipt.swift` | 43 |

Hard fail >400: **pass** (max 167).

## Honesty

- Visual + spoken worker gap = `workerGapCopy` constant  
- `./scripts/wave-004-structure-check.sh` green  

## Gates

- guard OK · AtlasCoreChecks OK · BUILD SUCCEEDED · structure check OK  

## Residual

Arena SuiteSheet peels (out of scope). Conversation ExecutingStrip residual still deferred.
