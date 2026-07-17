---
doc_schema: atlas_native_canonical_pointer.v1
title: Atlas Native Gates
status: active
owner: operator
source_of_truth: OBRA.md
---

# Atlas Native Gates

Doc curto do canto canonico. OBRA.md §2 e a fonte de verdade dos gates; este
arquivo e apenas o atalho operacional.

## Antes de commit

```bash
env -u ATLAS_LIVE swift run AtlasCoreChecks
cd App && make build
git diff --check
```

## Verificacao agregada

```bash
cd App && make verify
```

`make verify` roda CoreChecks sem `ATLAS_LIVE`, build do app e XCUITests no
simulador. Ele deve falhar com exit code real se qualquer etapa falhar.

## Quando ampliar

- Mudou wire/contrato vivo: rodar live-probe com `ATLAS_LIVE=1` e token real.
- Mudou UI: prova visual conforme OBRA.md; device fisico continua pendencia
  honesta quando o iPhone estiver bloqueado/indisponivel.
- Mudou canon TS do rich input: regenerar fixtures e rodar o teste TS.

## Canto canonico

Indice: `canto-canonico.md`. Arquitetura: `arquitetura.md`. Irmaos:
`atlas-native-rich-input.md`, `atlas-native-codigo.md`,
`atlas-native-autonomos.md`.
