# META GOAL — Implementar integralmente a proposta Fable 5 “Execução Viva” no Atlas Native

> Cole todo este documento como Goal do agente coordenador. Ele é um contrato de
> implementação, fidelidade visual, integração e prova. Não é um convite para
> reinterpretar o design.

## Papel

Você é o coordenador-executor responsável por transformar a proposta vencedora
do Fable 5 em produto SwiftUI nativo, real e utilizável no iPhone. Coordene duas
trilhas estritamente separadas na mesma `main` local:

1. **FUNCIONA / Codex:** AtlasCore, contratos, models, streaming, persistência,
   ActivityKit wiring, build, checks e provas.
2. **CASCA / Fable:** SwiftUI, layout, componentes, tipografia, motion, haptics,
   assets e composição visual.

As trilhas cooperam exclusivamente pelos models `@Observable` e tipos públicos
do AtlasCore. Quem não é dono não invade o arquivo do outro: registra pedido em
`OBRA.md §5`, entrega o contrato, então conecta a casca.

## Objetivo terminal

Implementar **toda** a experiência apresentada em:

`/Users/vitorepf/develop/Atlas/atlas-native/docs/proposals/fable-5.html`

Autoridade visual congelada desta obra:

- versão: Fable 5 v9;
- commit-base de referência: `3906677`;
- SHA-256 observado na criação deste Goal:
  `9d4f7742a48513ecc1c211e329e746c272c0e004a8bcd46028526103bc110ae8`;
- esse SHA já inclui WIP concorrente do Fable sobre o runner das cenas. No
  início da execução, recalcule o SHA e trate o arquivo mais novo presente na
  `main` compartilhada como autoridade. Se houver mudança, faça diff, atualize
  a matriz de fidelidade e preserve-a; nunca reverta o Fable para forçar o SHA
  registrado aqui;
- conteúdo: Ato I completo, 13 situações operacionais e Ato III Autônomos 24/7.

O resultado deve ser a tradução nativa fiel dos mockups, não “inspirado neles”.
Não altere, simplifique, reorganize, substitua ou acrescente um espaço,
componente, ordem, hierarquia, raio, cor, fonte, texto, ícone, estado, movimento
ou superfície sem autorização expressa do operador. Quando SwiftUI e HTML
medirem de maneira diferente, preserve a **geometria percebida** do mock no
iPhone e documente a conversão de pontos; nunca redesenhe por preferência.

Ao terminar, o Atlas deve funcionar de verdade: nenhum botão falso, nenhum
status inventado, nenhuma ferramenta simulada, nenhum progresso decorativo e
nenhuma resposta quebrada. O HTML governa a apresentação; o runtime real governa
os dados.

## Fontes obrigatórias — leia antes de editar

Leia integralmente, nesta ordem:

1. `AGENTS.md`
2. `CLAUDE.md`
3. `OBRA.md`
4. `docs/proposals/fable-5.html` — HTML, CSS e JavaScript; o CSS contém as
   medidas/tokens e o JS contém a coreografia temporal.
5. `docs/proposals/fable-execucao-viva/index.html` — espelho histórico para
   conferir cenas, sem poder sobrepor `fable-5.html`.
6. `docs/proposals/codex-execucao-viva/index.html` — apenas para recuperar
   contratos ou estados anteriores úteis; não é autoridade visual.
7. `docs/proposals/codex-autonomos-command-center/index.html` — contrato de
   profundidade do Autônomos; a aparência continua sendo a do Fable.
8. `App/Atlas/AtlasTheme.swift`
9. `App/Atlas/AtlasType.swift`
10. `App/Atlas/AtlasMotion.swift`
11. `App/Atlas/RootView.swift`
12. `App/Atlas/WorkspaceView.swift`
13. `App/Atlas/ConversationView.swift`
14. `App/Atlas/ConversationChrome.swift`
15. `App/Atlas/ConversationCockpit.swift`
16. `App/Atlas/ConversationModel.swift`
17. `App/Atlas/AtlasSession.swift`
18. `App/Atlas/TurnPresence.swift`
19. `App/Atlas/AtlasActivityAttributes.swift`
20. `App/Widgets/AtlasWidgets.swift`
21. `App/project.yml`
22. `App/Makefile`
23. `App/scripts/run-device.sh`
24. `App/scripts/run-device-proof.sh`
25. `App/UITests/AtlasDeviceProofTests.swift`
26. `Sources/AtlasCore/AtlasAgentActivity.swift`
27. `Sources/AtlasCore/AtlasExecutionProof.swift`
28. `Sources/AtlasCore/InteractionRun.swift`
29. `Sources/AtlasCore/AtlasAiJobs.swift`
30. `Sources/AtlasCore/AtlasAiDecisions.swift`
31. `Sources/AtlasCore/AtlasAiQuality.swift`
32. `Sources/AtlasCore/AtlasNetworkFailure.swift`
33. `Sources/AtlasCore/RichInputEngine.swift`
34. checks relacionados em `Sources/AtlasCoreChecks/`.

Antes da primeira mudança, rode:

```bash
cd /Users/vitorepf/develop/Atlas/atlas-native
/Users/vitorepf/develop/Atlas/atlas-server/bin/atlas aobg workspace activate --json
/Users/vitorepf/develop/Atlas/atlas-server/bin/atlas open-brain context \
  "Implementar integralmente Fable 5 Execucao Viva no atlas-native" --json
git status --short
shasum -a 256 docs/proposals/fable-5.html
swift run AtlasCoreChecks
cd App && make build
```

Se o Open Brain estiver indisponível, registre o bloqueio e continue usando os
arquivos canônicos e verificações diretas do repo. Não invente contexto.

## Regra de ouro de fidelidade

O agente deve tratar cada superfície do HTML como um frame de referência. Para
cada frame:

- reproduzir exatamente a paleta Ink & Brass do mock:
  `bg #10181e`, `app-bg #1d2b34`, `surface #243743`,
  `surface-hi #2d4351`, `recessed #15212a`, `ink #d6dde2`,
  `ink2 #95a3ac`, `ink3 #677482`, `separator #313f47`,
  `separator-soft #27353e`, `gold #d4a85a`, `green #7fb069`,
  `alert #c98a8a`;
- usar Fraunces e JetBrains Mono já incluídas em `App/Atlas/Fonts/`; SF Pro é
  usada somente onde o mock define `sans`;
- manter pesos, itálicos, tamanhos, line-height, tracking, limites de linha,
  alinhamentos, padding, gaps, bordas, divisores, cápsulas, raios e sombras;
- manter a ordem exata dos elementos, a densidade editorial e o uso deliberado
  de vazio;
- manter a diferença semântica entre voz/intenção do agente em Fraunces
  itálico, ferramentas em sans/mono e provas/telemetria em mono;
- manter a coreografia do JavaScript: sequência, entrada, assentamento, pulso,
  morph, contadores, timers e conclusão. Converter CSS easing para SwiftUI com
  curvas equivalentes, especialmente `cubic-bezier(0.32, 0.72, 0, 1)`;
- haptics devem marcar somente transições significativas mostradas no mock:
  plano pronto, atenção necessária, ação concluída, retomada e obra concluída;
- `Reduce Motion` elimina deslocamento/pulso contínuo, mas preserva mudança de
  estado e hierarquia. Não remover componentes;
- não adicionar VoiceOver como elemento visual nem voz lendo a tela. Manter
  apenas acessibilidade sem alterar o mock: labels, traits, ordem de foco,
  Dynamic Type controlado e contraste;
- preservar o composer utilizável durante toda execução.

Crie uma régua central de tokens/medidas derivada do HTML; não espalhe números
duplicados. Essa régua não autoriza alterar valores. Use componentes profundos
e pequenos, sem criar uma megaview: view acima de aproximadamente 200 linhas é
candidata obrigatória a split; arquivo geral acima de 300 linhas exige
justificativa em `OBRA.md`.

## Produto que deve existir

### Ato I — conversa viva, conclusão e continuidade fora do app

Implemente a mesma conversa em dois estados sincronizados:

1. **Durante a execução**
   - quote do usuário;
   - pill de progresso `Passo N/M · arquivos · +linhas −linhas` somente com
     dados reais;
   - narrativa cronológica que preserva intenção pública, ferramentas
     agregadas, arquivo/linha e ação atual;
   - nó atual pulsa; nós anteriores ficam assentados; nada desaparece;
   - timer e contagem de eventos reais;
   - botão `Parar` cancela pelo model/Core;
   - composer permanece editável;
   - mensagem enviada durante o turno entra automaticamente na fila FIFO.

2. **Depois de concluir**
   - `Obra concluída` com passos, arquivos e duração reais;
   - provas em três células;
   - resposta final limpa, sem Reasoning bruto e sem fragmentação de stream;
   - eixos de mudança, artefato, ações `Inspecionar`, diff e evidências;
   - assinatura no mesmo lugar do mock, usando identidade provider-safe do
     contrato em produção; fixtures visuais podem reproduzir o texto de
     referência;
   - feedback pills na mesma ordem.

3. **Tela bloqueada e Dynamic Island**
   - uma Live Activity por sessão ativa;
   - N sessões reais, cada uma com título, fase e timer próprios;
   - contador compartilhado `× N`;
   - estado de plano concluído, resposta pronta, atenção e sessão encerrada;
   - notificação de conclusão com título, thread e trecho útil;
   - push/APNs para turnos longos em background deve ser uma fase contratada e
     honesta; a limitação local atual nunca pode ser mascarada;
   - quando o sistema permitir, tap abre a sessão correta, não uma conversa
     genérica.

### Ato II — as 13 situações, todas funcionais

Implemente cada situação como estado real reutilizando a linguagem visual do
mock. Não as transforme em uma galeria de demo dentro do produto.

1. **Atenção necessária:** permissão/decisão tipada, motivo, risco, opções
   reais, timer pausado e retomada sem duplicar o turno.
2. **Replanejamento honesto:** plano real N/M, causa pública da mudança,
   versão anterior preservada, novo plano e retomada no passo correto.
3. **Reconexão sem perda:** offline/timeout/conexão recusada distinguidos,
   último sequence/checkpoint, backoff, retomada sem duplicar eventos e estado
   visual exatamente como o mock.
4. **Aguardando sistema externo:** receipt externo, próxima verificação,
   deadline e ações reais; não mostrar Atlas “pensando”.
5. **Orquestra de agentes:** quantidade e identidade pública dos agentes,
   status, missão, dependência, subagente aguardado, agregação legível e
   histórico persistente.
6. **Missão noturna:** a cena temporal do mock deve existir na vertical
   Autônomos, não dentro de conversa comum; missão, limites, marcos e resumo da
   manhã.
7. **Revisão entre agentes:** autor, revisor, achados, decisões, correções e
   prova final, preservando a troca cronológica.
8. **Continuidade entre devices:** mesma sessão canônica em iPhone, Desktop e
   Terminal; handoff real, nenhum prompt copiado, nenhum histórico duplicado.
9. **Voz contínua:** estados ouvindo, respondendo e executando, legenda parcial,
   interrupção real e reflexo equivalente na Dynamic Island. Não simular
   LiveKit se o contrato ainda não estiver disponível: implemente a vertical ou
   marque dependência, nunca um botão morto.
10. **Artefato pronto:** arquivo real, tipo, tamanho, idioma, checks, arquivos,
    warnings, resumo, ledger e ações reais `Abrir resultado`, `Ver diff`, `Ver
    provas`; ações acendem somente após prova.
11. **Fila durante execução:** chip `Fila N`, composer sempre utilizável,
    bottom sheet idêntico ao mock, adicionar por botão/Return, remover e
    `enviar agora` como próximo item sem matar o turno atual; drenagem FIFO
    automática; fila persiste ao navegar e voltar.
12. **Revisar mudanças:** totais `+/-`, arquivos, trecho de diff, aceitar tudo,
    decidir por arquivo e rejeitar; decisões registradas no ledger. Não criar
    editor de código diferente do mock.
13. **Falha honesta:** nome, causa, etapa N/M, checkpoint, ações `Retomar`,
    `Diagnóstico`, `Encerrar`, timer sobrevivente e continuação na sequência
    seguinte sem duplicar histórico.

### Ato III — Autônomos 24/7 em superfície própria

Autônomos **não** é card do Agent Cockpit, conversa longa ou sessão comum. Crie
uma rota/área superior própria, mantendo exatamente a aparência do Command
Center Fable:

- cabeçalho `Autônomos` e resumo executando/atenção;
- quatro métricas no mesmo grid;
- lista de instâncias com missão, placement humano, host/runtime,
  workspace/repo, branch, agentes, passo, uptime, heartbeat, lease e progresso;
- status executando, aguardando, pausado, stale, falha e atenção;
- incidente de lease por exceção, com transferência, espera e abertura da
  instância;
- digest do operador; trabalho saudável vira digest, não spam;
- tela de detalhe com missão, objetivo, limites, estágio, plano, agentes,
  ferramentas, tasks, implementado/não implementado, arquivos/diffs/commits,
  artifacts, receipts, decisões, incidentes, handoffs, recuperações e provas;
- Cérebro Externo e Músculo Externo via contrato provider-safe, com ações
  copiar/abrir/usar; detalhes brutos somente em modo explícito de auditoria;
- controles reais e governados: criar, seguir, pausar, retomar, drenar,
  transferir, reexecutar, cancelar e encerrar;
- sobrevivência a relaunch, troca de device e app fechado.

O HTML inclui Autônomos no Ato III para contar a proposta; no app ele deve ser
uma área independente conforme a decisão canônica de `OBRA.md`.

## Componentes nativos esperados

Faça o split por responsabilidade, reaproveitando e refinando o que já existe.
Nomes podem mudar apenas para encaixar a estrutura atual, nunca o layout:

- `ExecutionNarrativeView` — quote, plan pill, fio, intenção, ferramentas e
  ação atual;
- `ExecutionComposer` — anexar, entrada, voz, fila, stop;
- `QueuedFollowUpsSheet` — contador, lista, promover e remover;
- `ExecutionCompletionView` — obra, provas, resposta, eixos, artifact e
  feedback;
- `AttentionRequiredView`;
- `ReplanHistoryView`;
- `ConnectionRecoveryView`;
- `ExternalWaitView`;
- `AgentOrchestraView`;
- `PeerReviewView`;
- `ContinuityHandoffView`;
- `VoiceExecutionView`;
- `ArtifactProofView`;
- `ChangeReviewView`;
- `HonestFailureView`;
- `AutonomosFleetView` e detalhe de instância;
- Live Activity lock-screen, expanded/compact/minimal Dynamic Island;
- presentation-only state/adapters sem rede, storage ou parsing de wire.

Não duplique `AtlasTheme`, não introduza TCA, não adicione dependência e não
crie protocol sem segundo consumidor real. Arquitetura: Swift 6,
`@Observable @MainActor` na casca de estado, `actor` para trabalho concorrente,
`AsyncSequence` para stream e Foundation/SwiftUI/ActivityKit nativos.

## Contratos funcionais que precisam ser fechados

Antes de ligar uma cena, verifique se o model/Core fornece o dado. Se faltar,
a trilha CASCA registra o pedido em `OBRA.md §5`; a trilha FUNCIONA entrega o
contrato com golden check. No mínimo:

- `QueuedMessage` e fila persistente FIFO: lista, adicionar, promover próximo,
  remover e autodrenar;
- plano real: título, passos, índice atual, total, versões e motivo do replan;
- timeline pública sanitizada: intenção, leitura, busca, execução, edição,
  conclusão e warning;
- agregados de diff/arquivos e artifact/proof;
- checkpoint/resume/failure tipados;
- decisões e pedidos de permissão tipados;
- identidade/estado/dependência de agentes;
- receipts de sistema externo;
- session identity e handoff cross-device;
- voz e interrupção;
- frota Autônomos, placement, heartbeat, lease, ledger, prompts provider-safe e
  comandos governados;
- deep link da Live Activity para a thread correta;
- APNs de atualização/conclusão quando necessário.

Se um campo ainda não existir, a UI mostra um estado honesto previsto no mock
ou fica bloqueada até o contrato. É proibido inventar número, porcentagem,
arquivo, modelo, agente, ferramenta, diff, checkpoint, prova ou sucesso.

## Plano de execução obrigatório

Execute verticais pequenas e demonstráveis, sempre red → green → device:

### Fase 0 — baseline e matriz de fidelidade

- preservar todo WIP existente;
- registrar claims/escopos em `OBRA.md` usando `.atlas-mobile-plan.lock`;
- capturar cada estado do HTML em imagens de referência;
- criar uma matriz cena → estado → contrato → view → teste → screenshot;
- medir o mock, não estimar de memória;
- registrar baseline dos gates.

### Fase 1 — Ato I completo

- fechar timeline, plano real, composer, fila e conclusão;
- eliminar resposta quebrada/Reasoning bruto;
- conectar ActivityKit multi-sessão e deep link;
- provar no iPhone físico durante e depois.

### Fase 2 — situações 1–5

- atenção, replan, reconnect, espera externa e orquestra;
- cada estado vem de contrato real e permanece consultável.

### Fase 3 — situações 7, 10–13

- revisão entre agentes, artifact, fila, diff e falha honesta;
- priorizar as superfícies já sustentadas pelo Core atual.

### Fase 4 — Continuity e Voice

- implementar handoff canônico e voz real;
- não reduzir o mock a placeholders.

### Fase 5 — Autônomos 24/7

- rota própria, frota, detalhe, incidentes, digest, prompts e comandos;
- backend/Core primeiro, projeção SwiftUI depois.

Uma fase só termina com código, contrato, teste, build, screenshot e registro de
prova. “Estrutura pronta” não conta como entrega.

## Main compartilhada e proteção do trabalho existente

- Trabalhe somente na `main` local; não crie worktree e não faça merge.
- Há WIP simultâneo. Antes de todo patch/commit: releia `OBRA.md` e rode
  `git status --short`.
- Não reverta, sobrescreva, formate em massa ou inclua mudanças de outro agente.
- Stage explícito por arquivo; nunca `git add -A`.
- Commits da trilha FUNCIONA: `feat(core)` / `fix(core)`.
- Commits da trilha CASCA: `feat(ui)` / `polish(ui)`.
- Se dois agentes precisarem do mesmo arquivo, pare, registre o seam e
  sequencie; não tente resolver por merge posterior.

## Testes e provas obrigatórios

Em cada slice:

```bash
cd /Users/vitorepf/develop/Atlas/atlas-native
swift run AtlasCoreChecks
cd App
make build
```

Quando houver wire/endpoint/contrato e credenciais disponíveis:

```bash
ATLAS_LIVE=1 ATLAS_TOKEN="$ATLAS_TOKEN" swift run AtlasCoreChecks
```

Para entrega visual/funcional:

```bash
cd /Users/vitorepf/develop/Atlas/atlas-native/App
make device
make device-proof
```

Adicione/expanda:

- golden checks para toda lógica nova;
- checks de boundary que impedem View de fazer rede, JSON ou storage;
- XCUITests por jornada e estado, não somente existência de labels;
- fixtures determinísticas exclusivamente para screenshot tests, claramente
  separadas do runtime de produção;
- screenshots do HTML e do iPhone na mesma cena/estado;
- comparação visual lado a lado e, quando viável, pixel diff com máscara apenas
  para status bar, timer e conteúdo genuinamente dinâmico;
- Instruments no device para scroll, streaming e composer: nenhuma decodificação
  pesada no `body`, nenhum update por token que reconstrua a tela inteira,
  nenhuma queda perceptível durante 120 Hz;
- relaunch, background, rede perdida, duas sessões simultâneas e fila drenando.

## Gate de fidelidade — zero “quase igual”

Uma cena só é aceita quando:

1. contém exatamente os componentes do mock, na mesma ordem;
2. espaçamentos, tamanhos, raios, tipografia, cores e divisores foram medidos a
   partir do HTML e conferidos no screenshot;
3. movimento reproduz a mesma narrativa temporal;
4. todos os controles executam ações reais;
5. dados vêm do model/Core ou são fixtures isoladas de teste;
6. o estado permanece registrado e consultável após a conclusão;
7. loading, erro, cancelamento, background e reconnect são honestos;
8. o composer nunca vira um cartão estático de “trabalhando”;
9. o agente não adicionou abstração, componente ou superfície ausente do mock;
10. operador consegue reconhecer a tela do Fable sem explicação.

Se houver divergência visual, corrija o SwiftUI para o mock. Não altere o HTML
para fazer o diff passar.

## Critério de conclusão do Goal

Não declare conclusão parcial como final. O Goal termina somente quando:

- Ato I, todas as 13 situações e Autônomos próprio estão implementados;
- todos os contratos necessários existem e têm checks;
- execução real mostra intenção pública, ferramentas, agentes, progresso,
  fila, diff, provas, falhas e conclusão sem vazamento de conteúdo interno;
- lock screen/Dynamic Island representam N sessões reais e atualizam fora do
  app conforme o contrato disponível;
- todos os controles são reais;
- relaunch/reconnect/background preservam estado;
- Core checks, app build, live probes aplicáveis e device proof estão verdes;
- cada cena possui screenshot final comparado com o Fable;
- `OBRA.md` registra tarefas, commits e evidências;
- nenhum warning próprio novo, nenhuma dependência nova e nenhuma regressão de
  performance foi introduzida.

## Relatório obrigatório a cada entrega

Atualize o operador em pt-BR com:

```text
SLICE: <ato/cena>
RESULTADO VISÍVEL: <o que já funciona no iPhone>
CONTRATO REAL: <tipos/endpoints/estados usados>
FIDELIDADE: <screenshot Fable x screenshot device e divergências restantes>
PROVAS: <checks, build, live probe, XCUITest, device>
ARQUIVOS: <lista exata>
COMMIT: <hash escopado>
PRÓXIMO: <próxima vertical>
BLOQUEIOS HONESTOS: <somente fatos; sem porcentagem inventada>
```

Não use frases como “pronto”, “perfeito”, “100%” ou “world-class” sem todas as
provas acima. O sucesso deste Goal é simples: **o mock vencedor do Fable existe
no Atlas Native com a mesma experiência visual e com comportamento real — sem
um único componente decorativo ou divergência criativa.**
