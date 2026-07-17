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

## ONDE os gates RODAM — matriz de ambiente (leia antes de despachar agente)

**Todos os gates deste repo exigem macOS — o Mac do operador.** Nenhum gate
roda em Linux (pod de nuvem, CI Linux, container):

| Gate | Comando | Exige | Roda em Linux? |
|---|---|---|---|
| Golden checks | `swift run AtlasCoreChecks` | toolchain Swift **da Apple**: `CryptoKit` (AtlasCore) e `ImageIO/CoreGraphics` (AtlasImaging) são frameworks Apple-only — **nem compila** em Swift-Linux | ❌ |
| Build do app | `cd App && make build` | Xcode + SDK iOS (`xcodebuild`) | ❌ |
| XCUITest simulador | `make verify` / `xcodebuild test` | Xcode + Simulator (macOS) | ❌ |
| Deploy device | `make device` | `xcrun devicectl` + iPhone pareado **no Mac** (mesmo WiFi) | ❌ |
| Prova física | `make device-proof` | idem + iPhone desbloqueado | ❌ |
| Live-probe | `ATLAS_LIVE=1 ATLAS_TOKEN=… swift run AtlasCoreChecks` | os itens acima + atlas-server local (:3737) | ❌ |

**Por que o pareamento não ajuda um agente na nuvem:** o iPhone é pareado ao
MAC (CoreDevice/devicectl). Um pod Linux não tem caminho USB/rede até o
aparelho, não tem `xcrun`, não tem Xcode — e o próprio executável de checks
não compila fora da toolchain Apple.

### Protocolo por tipo de agente

- **Agente LOCAL no Mac** (Claude Code/Cursor/terminal no Mac): caminho
  canônico. Roda todos os gates; commita direto na main local com os gates
  verdes. É assim que as obras deste repo sempre validaram.
- **Agente na NUVEM (pod Linux)**: NÃO pode validar nada deste repo.
  Regra: trabalho de nuvem chega como branch/PR e **só entra na main depois
  que um agente/operador NO MAC roda a bateria completa** (checks + build +
  verify) sobre o resultado e registra em OBRA §7. Merge sem gates rodados
  no Mac = commits sem prova (a regra "main local, sem merges" existe
  exatamente para impedir isso; exceção de PR exige decisão do operador em
  §6 E a bateria no Mac antes do merge).
- **Alternativa para nuvem validar sozinha**: self-hosted worker/runner NO
  Mac (o agente da nuvem despacha os comandos para o Mac executar). Sem
  isso, a nuvem escreve código, o Mac prova.

### Bateria pós-merge de PR (obrigatória, no Mac)

```bash
cd /Users/vitorepf/develop/Atlas/atlas-native
env -u ATLAS_LIVE swift run AtlasCoreChecks   # exit 0
cd App && make build                          # exit 0
make verify                                   # XCUITests simulador
git diff --check
```
Resultado (exit codes literais) registrado em OBRA §7 junto do hash do merge.

## Canto canonico

Indice: `canto-canonico.md`. Arquitetura: `arquitetura.md`. Irmaos:
`atlas-native-rich-input.md`, `atlas-native-codigo.md`,
`atlas-native-autonomos.md`.
