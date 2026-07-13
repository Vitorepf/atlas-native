# Rich Input Shared Core — análise rigorosa + arquitetura Swift (iOS hoje, macOS depois)

> Gerado 2026-07-12 por análise multi-agente (5 leitores: mobile RN, desktop Tauri,
> atlas-server, camada de compartilhamento, estado Swift; 3 propostas de arquitetura;
> 2 juízes). Este doc é o canon do rich input para a migração Swift.

## Parte 1 — O que existe hoje (a verdade verificada)

### 1.1 A tese "melhorar um melhora o outro" é PARCIALMENTE verdade

**Verdade estrutural (com enforcement por teste)** — a camada de **CONTRATO** é
compartilhada de verdade via pacote `@atlas/rich-input-canon`
(`/Users/vitorepf/develop/Atlas/packages/atlas-rich-input-canon`), dependência `file:`
nos dois apps:

- schema `atlas.rich_input.payload.v1` + tipos
- `ATTACHMENT_LIMITS` (8 imgs / 4 PDFs / 8 texts / 16 URLs / 20MB / chunk 1.5MB)
- `urlDetector` (extractUrls/classifyUrl — YouTube/Vimeo/GitHub/generic)
- `sourceManifest` (buildRichInputPayload / buildSourceManifestFromDrafts)
- `uploadRetry` (withRetry 3× 280ms×2^n) — único pedaço de **runtime** unificado
- `__tests__/cross-platform-contract.test.ts` trava byte-identidade do payload

Mobile `lib/richInput/*` = 8 shims de 1 linha para o canon. Desktop
`lib/rich-input/types|urlDetector|metrics` idem.

**Aspiração (documentada, não cumprida)** — a camada de **RUNTIME** (aquisição,
processamento, upload, estado de draft) são DUAS implementações independentes:

- Desktop: `useAtlasRichInputAttachments.ts` (456 linhas) + `imageProcessor` (resize
  2048px q0.86, alpha-detect, GIF bypass) + `pdfProcessor` (pdfjs: texto 200k chars
  `[p.N]`, thumbnail) + `chunkedUploader.ts` (1.5MB/chunk, sem resume).
- Mobile: `AtlasAiAttachmentModel.ts` (expo pickers, **sem processamento — bytes
  crus**) + `uploadAiAttachmentInChunks` embutido em `lib/api/atlasAi.ts`
  (768KB/chunk, **com resume** via client_upload_id FNV-1a) + fallback multipart.
- O doc canônico `atlas-hyperflow-operation-surface-rich-input.md` proíbe o mobile de
  duplicar runtime — o mobile de hoje **viola** isso; o anti-regression scan só cobre
  `apps/desktop/src/surfaces/*`, então o runtime paralelo do mobile passa despercebido.
- Nota: os "dois chunkedUploaders do desktop" são falso positivo —
  `surfaces/atlas-ai/attachments/*` são shims mortos re-exportando `lib/rich-input`.
  A duplicação real de uploader é **mobile vs desktop**.

### 1.2 Catálogo do drift (prova de que espelho diverge)

| Eixo | Mobile RN | Desktop Tauri | Consequência |
|---|---|---|---|
| Chunk size | **768KB hardcoded** | 1.5MB (canon) | mobile ignora a constante canônica |
| Resume | **sim** (client_upload_id FNV + received_chunks) | **não** | melhoria do mobile nunca chegou ao desktop |
| `source` default | `'app'` | `'atlas_rich_input'` | mesmo campo, semântica diferente no backend |
| text_blocks | **sempre []** (sobe .ts como documento) | inline com content+language | mesmo arquivo, semântica backend diferente |
| URL drafts | só extractUrls do texto | addUrl com metadata oEmbed rica | UX divergente |
| Processamento img | nenhum (bytes crus) | resize 2048px q0.86 | uploads maiores no pior link |
| Limites | hardcoded (aceita text 20MB!) | ATTACHMENT_LIMITS (text 4MB) | mobile aceita o que o server rejeita |
| Compact rule | `hasRichInputPayload` inline (manifest CONTA) | `compactRichInput` (manifest NÃO conta) | mesma decisão, regra diferente |

### 1.3 O contrato canônico do servidor (o que o Swift TEM que falar)

Endpoints (grupo `atlas.token`, header `X-Atlas-Token`, prefixo `/api`):

```
POST /ai/uploads/chunks/start     { client_upload_id?, kind: image|file, file_name,
                                    mime_type, total_bytes: 1..20971520, source? }
                                  → { upload: { id, received_chunks[] } }   # idempotente/resume
POST /ai/uploads/chunks/{id}/chunk { index: 0..10000, total_chunks, offset (IGNORADO),
                                    bytes (tamanho DECODIFICADO), chunk_base64 }
                                  # valida strlen(decode)==bytes; máx decodificado 1_572_864
POST /ai/uploads/chunks/{id}/complete {} → { upload: { id, sha256, bytes, ... } }
POST /ai/interactions             { input_text, uploaded_images?: [id] (máx 8),
                                    uploaded_documents?: [id] (máx 4),
                                    rich_input_payload?, payload?, ... } → 202 { trace }
```

**Gotchas críticos do servidor (cada um custou um bug em potencial):**

1. **ANEXO REAL vs METADADO**: `rich_input_payload.uploaded_image_ids` NÃO anexa nada
   — serve só pro AtlasDecide detectar visão. O que anexa é `uploaded_images` /
   `uploaded_documents` no **NÍVEL RAIZ** do create.
2. **HEIC é rejeitado** (422): o server re-sniffa MIME via `getimagesize`; whitelist
   png/jpeg/webp/gif. Foto de iPhone TEM que virar JPEG no cliente.
3. **Extração de PDF é SÍNCRONA no create** (parse + pdftoppm + OCR antes do 202) —
   timeout do cliente ≥120s com documentos.
4. `payload`/`rich_input_payload` como string JSON inválida → **null silencioso** (sem erro).
5. `kind` do start é meta; o pipeline real é decidido pelo array do create.
6. YouTube em url_attachments exige `ref_id` de 11 chars (`^[A-Za-z0-9_-]{11}$`) — 422 sem ele.
7. `client_upload_id` NÃO é escopado por device — ids iguais de clientes diferentes
   **colidem** no staging.
8. text_blocks só são consumidos pelo **Forge** (programming) — no chat comum um .ts
   como text_block NÃO entra no prompt.
9. Staging `storage/app/ai/uploads` **nunca é limpo** (config `ttl_hours` existe e
   nenhum código a lê). Anexos processados: cleanup 7d só via AiChatCommand.
10. Sem checksum por chunk do cliente; o `sha256` do complete é a única verificação
    fim-a-fim — o cliente DEVE conferir.
11. Anexo chega ao provider como **arquivo em disco** (Claude: `--add-dir` + Read
    tool; Codex: `--image {path}`), nunca base64 no prompt.

### 1.4 Estado do Swift (atlas-native)

"Leitura pronta, escrita ausente": `AtlasAiAttachments.swift` (128 linhas) tem DTOs de
leitura; `AtlasClient` tem verbos JSON + SSE, **sem** upload; `CreateAiInteractionInput`
não tem uploaded_images/documents/rich_input_payload; `Package.swift` já declara
plataformas que servem o futuro macOS; o padrão AtlasCoreChecks (golden checks CLI +
live probes) é a fundação de teste perfeita para isto.

## Parte 2 — A arquitetura: **AtlasRichInput contract-first, engine única**

Vencedora do painel (2 juízes, 9.0 e 8.5/10), emendada com as melhores ideias das
outras duas propostas.

### Tese

O contrato do atlas-server é a única fonte de verdade e o AtlasCore o materializa 1:1.
Toda a pipeline (classificação, chunking, resume, retry, progresso, builder do payload,
montagem do create) vive num **único actor Foundation-only** no AtlasCore. iOS e o
futuro macOS consomem o MESMO engine — "melhorar um melhora o outro" vira verdade **por
construção**, porque não existe outro lado: existe um core e dois adaptadores de
aquisição de ~100 linhas.

### Camadas

```
L0  AtlasClient (existe)      transporte HTTP/SSE — ganha só a conformance UploadTransport
L1  RichInputContract.swift   espelho 1:1 do servidor: payload v1 (CodingKeys snake_case
                              EXPLÍCITAS), wire DTOs chunked, AtlasAttachmentLimits pinados,
                              URLDetector. Zero lógica, zero I/O.
L2  RichInputEngine.swift     actor: drafts, chunk math, resume, retry, SHA-256 streaming
                              (CryptoKit), progresso agregado, RichInputPayloadBuilder
                              (o ÚNICO builder do universo Swift), compact rule única,
                              montagem do create (uploaded_* RAIZ + espelho no payload).
L3  AtlasImaging (target SPM) ImageIO/CoreGraphics (iOS E macOS, sem UIKit/AppKit):
                              HEIC→JPEG obrigatório, resize 2048px, q0.86, PNG-alpha
                              preservado, GIF bypass. UM código para as duas plataformas.
L4  Adapters de aquisição     iOS: PhotosPicker/fileImporter/pasteboard/câmera →
    (por app, fora do core)   AttachmentInput. macOS futuro: NSOpenPanel/drag-drop/
                              NSPasteboard → o MESMO AttachmentInput. ~100 linhas cada.
L5  Feature layer (app)       ConversationModel: draft state p/ UI, progress, outbox
                              futuro. AttachmentState enum é o ÚNICO contrato de UI.
```

### Os dois seams (e só esses)

1. **`AttachmentByteSource`** — a plataforma entrega bytes por offset
   (`read(offset:length:)`); o core nunca vê PhotosPickerItem/NSOpenPanel/URI.
   Defaults no core: `DataByteSource`, `FileByteSource` (FileHandle).
2. **`UploadTransport`** — protocol de 3 métodos espelhando os 3 endpoints
   (emenda da proposta P2, sanando a falha apontada pelos juízes: o loop de upload
   fica testável offline via `InMemoryUploadTransport`; `extension AtlasClient:
   UploadTransport` é a implementação real).

### Decisões explícitas (cada uma resolve um drift catalogado)

| Decisão | Valor | Racional |
|---|---|---|
| Chunk size | **1.5MB** (limite do server) | mata o drift 768/1536; se LTE doer, muda UMA constante — nunca fork por plataforma |
| Resume | **sim**, chave estável + `installSalt` (UUID persistido por instalação) | preserva a melhoria do mobile E imuniza contra a colisão de staging do server |
| Chave de upload | hash estável Swift próprio — **SEM** replicar Math.imul bit-igual | resume cross-runtime não existe; os 2 juízes condenaram o esforço |
| source_hash | **preenchido** (CryptoKit streaming, de graça) | melhoria vs RN/desktop (ambos null); coberto por fixture como decisão, não drift |
| sha256 do complete | **sempre conferido** contra o hash local | única integridade fim-a-fim do protocolo |
| Fallback multipart | **NÃO portado** | só existia porque expo-file-system falha em leitura por offset; FileHandle não falha; fallback silencioso mascarava erros |
| text_blocks | default = comportamento RN (**documento**); inline **opt-in por fluxo** | server só consome text_blocks no Forge; a assimetria vira decisão gravada |
| Compact rule | única: payload nil se as 4 listas vazias (manifest NÃO conta) | resolve compactRichInput vs hasRichInputPayload |
| HEIC | validação de whitelist ANTES do start (falha local clara) + AtlasImaging converte | 422 do server nunca é a primeira notícia |
| Timeouts | 45s/chunk (base64 infla 33%), 120s create com documento, 90s sem | extração de PDF é síncrona no server |
| Erro no create | **nunca** re-sobe anexos; `UploadedAsset.id` reutilizável (re-send idempotente) | semântica preservada do RN |
| Outbox/recovery | L5, "quando doer" — política `shouldKeep` no core, storage no app | resiliência adiada sem perder o lugar canônico |

### Anti-drift estrutural (o que torna o drift IMPOSSÍVEL, não desencorajado)

1. **Fixtures compartilhadas TS+Swift**: script tsx no canon exporta
   `fixtures/*.json` (payload canônico, chunk math, golden values); o teste TS
   existente E o AtlasCoreChecks leem O MESMO arquivo. Mudar o canon quebra os dois
   lados — pino bidirecional.
2. **Live-probe opt-in** (`ATLAS_LIVE=1`, gate do `make device`): sobe 3.2MB reais →
   confere sha256; re-start prova resume no server real; create com anexo → verifica
   `visual_input.image_count` no trace (pega exatamente o bug "raiz vs metadado" que
   fixture offline nunca pega).
3. **Check de fronteira de imports** no AtlasCoreChecks: AtlasCore não importa
   UIKit/AppKit/SwiftUI/PhotosUI; **nenhum app target fala com `/ai/uploads/*`
   direto** — o segundo uploader não pode nascer (análogo Swift do anti-regression
   scan do desktop).
4. **Golden checks offline**: encode byte-idêntico à fixture, chunk math
   (ceil/offsets/último parcial), resume via ByteSource fake que CONTA reads
   (received=[0,2] → só 1,3 lidos), retry 280/560/1120, progresso monotônico
   multi-arquivo, sha256 streaming == sha256 de Data inteira, refId YouTube 11 chars.

### Caminho de migração (incremental, cada passo verde antes do próximo)

1. **Fixtures primeiro** — script tsx no canon exporta as fixtures; teste TS passa a
   lê-las. (Se este passo for pulado "para ir mais rápido", o Swift nasce como
   terceiro runtime divergente — exatamente a doença que a migração cura.)
2. **L1** — RichInputContract.swift + check de encode byte-idêntico.
3. **L2 puro** — chunk math, chave estável+salt, withRetry, builder, compact rule;
   golden checks offline com InMemoryUploadTransport.
4. **Transporte** — engine.upload sobre AtlasClient (start/chunk/complete, SHA-256
   streaming, resume); live-probe contra o atlas-server local.
5. **Create** — CreateAiInteractionInput ganha uploadedImages/uploadedDocuments/
   richInputPayload; engine.send com timeouts; live-probe verifica visual_input.
6. **AtlasImaging** — target novo, HEIC→JPEG/resize/q0.86; checks com fixtures de
   imagem no runner mac.
7. **iOS liga** — o `pickedPhoto` decorativo do ConversationView vira real:
   PhotosPickerItemSource → drafts na UI → send() com anexos. `make device`.
8. **Fontes restantes iOS** — fileImporter, clipboard, câmera; badges/limites na UI.
9. **Paridade de resiliência (quando doer)** — outbox durável (padrão
   PendingAiSubmission do RN), long-message >40k → .md, prewarm YouTube. Tudo L5.
10. **macOS quando chegar** — MacAttachmentAdapter (NSOpenPanel/drop/pasteboard) +
    composer SwiftUI. Engine, imaging, fixtures, checks: **intocados**. A migração do
    rich input do desktop vira só aquisição + UI.

### Riscos aceitos

- Entre os passos 7 e 9 há janela sem outbox (matar o app no meio do envio perde a
  mensagem — o RN hoje não perde). Regressão temporária conhecida.
- Sem fallback multipart, uploads que "funcionavam" via fallback silencioso passarão a
  exibir erro — comportamento melhor, mas visível.
- Pressão de paridade com RN vai tentar empurrar features de L5 pra dentro do core —
  defender a regra das camadas em review.
- Staging do server sem TTL: resume agressivo aumenta lixo em disco — fix no
  atlas-server (consumir a config `ttl_hours` que já existe), fora deste escopo.
