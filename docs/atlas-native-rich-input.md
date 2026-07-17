---
doc_schema: atlas_native_canonical_pointer.v1
title: Atlas Native Rich Input
status: active
owner: operator
source_of_truth: docs/rich-input-shared-core.md
---

# Atlas Native Rich Input

Doc curto do canto canonico. O dossie completo e
`rich-input-shared-core.md`; este arquivo existe para orientar a primeira leitura.

## Verdade atual

- Contrato de payload: `atlas.rich_input.payload.v1`.
- Engine unico: `AtlasRichInputEngine` em `Sources/AtlasCore/RichInputEngine.swift`.
- Seams: `AttachmentByteSource` e `UploadTransport`.
- Limite de chunk: 1.5MB, alinhado ao servidor.
- HEIC de iPhone vira JPEG via `AtlasImaging`; SHA-256 e resume vivem no Core.

## Onde mexer

- Contrato/payload/upload: `Sources/AtlasCore/RichInputContract.swift` e
  `Sources/AtlasCore/RichInputEngine.swift`.
- Normalizacao de imagem: `Sources/AtlasImaging/`.
- UI de draft/progresso: models em `App/Atlas/ConversationModel.swift` e casca
  SwiftUI que renderiza `LocalDraft`/`UploadProgress`.

## Gates

`env -u ATLAS_LIVE swift run AtlasCoreChecks` cobre payload, engine e boundary.
Mudanca visual ainda precisa de prova de UI conforme OBRA.md.

## Canto canonico

Indice: `canto-canonico.md`. Arquitetura: `arquitetura.md`. Irmaos:
`atlas-native-codigo.md`, `atlas-native-autonomos.md`,
`atlas-native-gates.md`.
