# WAVE-101 — provenance-file-row-judgment-instrument

**Status:** design · proposed  
**Wave:** `WAVE-101-provenance-file-row-judgment-instrument`  
**Owner:** casca only (Grok B / Implementer self-WAVE · residual full-bar)  
**Date:** 2026-07-21  
**Created by:** implementer (v5 · after 2 IDLE · fila vazia)  
**Δ patamar:** **high**  
**Rank:** (mechanical via regen)

---

## Problema

- Provenance (WAVE-057) tem face/pack no Judgment, mas **cada linha de
  arquivo** ainda fala via `AtlasCodeFileRowA11y` (verb soup + spokenFile).
- Operador de proveniência julga **diff de arquivos** — o dialeto A11y
  quebra a soberania do órgão.
- Residual pós-commit-row IDLE-25 / graph IDLE-26: file-row órfão.

## Patamar

| Antes | Depois |
|---|---|
| FileRowA11y verbs | **ProvenanceJudgment** spokenFile · verb |
| Pack face-only files count | pack file samples honesty |
| Body A11y soup | View wires Judgment only |

Δ = **soberania das linhas de arquivo da proveniência** — verb + spoken + pack.

---

## Arquitetura

### Princípios

- Casca only. Status/paths/add/del from published provenance files.
- Align verb words with Core status enum — never invent status.
- Zero Core · zero tipografia.

### Fluxo

```
AtlasCodeFileChange
  → AtlasCodeProvenanceJudgment
       spokenFile · verb(for:) · packFileFacts(files)
  → FileRow / FileRowBody wire
  → delete AtlasCodeFileRowA11y
```

### Arquivos (≥5)

1. `AtlasCodeProvenanceJudgment.swift` (extend)
2. `AtlasCodeFileRowBody.swift` (delete A11y · thin)
3. `AtlasCodeFileRow.swift` (wire)
4. `AtlasCodeProvenanceSections.swift` (optional pack value if list)
5. `App/Atlas/CODEMAP.md`
6. design + compress

### Densidade

Judgment +80–150 · Body −50 A11y · delete soup

### Fora de escopo

- Core provenance DTO  
- Diff renderer  
- Tipografia  

### §5

`nenhum`.

---

## DoD produto (≥5)

- [ ] spokenFile on ProvenanceJudgment.
- [ ] verb(for status) family on Judgment (mutate/rename/transform).
- [ ] Delete AtlasCodeFileRowA11y enum soup.
- [ ] FileRow call site Judgment-only.
- [ ] packFileFacts optional sample for loaded files.
- [ ] Gates + CODEMAP + DEVICE_PENDING.

## Anti-objetivos

- inventar status verb  
- fundir CommitRow com FileRow  
- tipografia  

## Plano W3

1. Extend ProvenanceJudgment spoken/verb/packFile.  
2. Rewire FileRow + Body.  
3. Delete A11y.  
4. CODEMAP.  
5. ~5–7 files · ~150–300 LOC.

## Proof

1. Added file VO: "path, adicionado, N linhas…".  
2. Binary: "arquivo binário" without inventing lines.  
3. Renamed: includes "de origin".  
4. DEVICE_PENDING.

## Council

Residual after viewer-100 + IDLE commit/graph peels. Completes
provenance file list organ.

### Rejection

Rename-only without A11y delete → fail.

### Density table

| File | Note |
|---|---|
| ProvenanceJudgment | spoken + verb + packFile |
| FileRowBody | A11y block gone |
| FileRow | one wire |

### Related

- CommitRowJudgment (commit identity — do not reopen)  
- GraphJudgment (map — done IDLE-26)  
- ArtifactListJudgment (trace artifacts — different domain)

### Verb table (honest)

| Status | Verb |
|---|---|
| added | adicionado |
| modified | alterado |
| deleted | removido |
| renamed | renomeado |
| copied | copiado |
| typeChanged | tipo alterado |
| unknown | mudança desconhecida |

### Pack file facts

```
prov_file_sample: <path> · <status>
prov_files_total: N
absence: nenhum arquivo na proveniência
```

Prefix ≤5 samples. Never invent path.

### W2 checklist

1. Judgment helpers  
2. Call sites  
3. Delete enum  
4. packFileFacts  
5. CODEMAP  
6. Gates  

### W3 checklist

1. compress  
2. DONE 101  
3. regen  
4. LEDGER waves=96  
5. feat(ui) commit  

### Risk

- `AtlasCodeFileStatus` switch must be exhaustive  
- Binary path: additions/deletions nil → "arquivo binário"

### Acceptance spoken

- "Sources/Foo.swift, alterado, 12 linhas adicionadas, 3 removidas"  
- "logo.png, adicionado, arquivo binário"  
- "Bar.swift, renomeado, de Old/Bar.swift, …"

### Why full-bar

- ≥5 files · completes provenance file organ · DoD≥5 · ≥120 design  
- Not IDLE: multi-file product sovereignty for file list judgment  

### Sequence after

1. Max 1–2 IDLE residual A11y  
2. Else wait A or TurnPresence residual WAVE  

---

*End WAVE-101 design.*
