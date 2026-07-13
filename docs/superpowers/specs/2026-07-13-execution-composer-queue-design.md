# Composer e fila durante a execução

## Objetivo

Corrigir a regressão da proposta `docs/proposals/codex-execucao-viva/index.html`
em que a barra “Seguindo a execução” substitui o composer. Durante uma obra, o
operador deve continuar escrevendo normalmente. Cada mensagem enviada entra na
fila do turno por padrão; interromper a execução exige uma ação separada e
explícita.

## Direção aprovada

O comportamento segue o padrão do Cursor mostrado pelo operador, traduzido para
o design Ink & Brass do Atlas:

- o composer permanece disponível durante toda a execução;
- enviar durante uma execução adiciona automaticamente a mensagem à fila;
- `Na fila N` não aparece quando a fila está vazia;
- depois do primeiro envio, o badge aparece junto ao estado compacto da obra;
- tocar em `Na fila N` abre uma bottom sheet com as mensagens na ordem de envio;
- cada mensagem oferece `Enviar agora` e `Remover`;
- `Enviar agora` interrompe/redireciona o turno atual e promove aquela mensagem;
- `Remover` descarta somente a mensagem escolhida;
- `Parar` continua sendo uma ação independente para cancelar a execução.

## Composição visual

### Estado compacto

O rodapé da conversa possui três camadas pequenas e coesas:

1. Estado da obra: fase atual, tempo, eventos e botão `Parar`.
2. Telemetria contextual: progresso/diff e o badge `Na fila N`, quando existir.
3. Composer normal do Atlas: anexo, campo de texto, voz/microfone e ação de
   envio.

O componente deve manter a linguagem do protótipo atual: fundo slate teal,
superfície discreta, borda fria, bronze somente para estado vivo e hierarquia
editorial. Não usar os círculos grandes com texto “Anexar”, “Voz” e “Parar” do
mock de brainstorming rejeitado. Controles iconográficos usam proporção e
densidade nativas do iPhone; `Parar` permanece reconhecível sem dominar o
composer.

### Fila expandida

A fila abre em uma bottom sheet nativa visualmente leve:

- grabber;
- título `Mensagens na fila` e contagem;
- lista cronológica;
- texto integral da mensagem, com expansão para textos longos;
- ações discretas `Enviar agora` e `Remover`;
- gesto de fechar e botão `Concluir`;
- execução continua visível, escurecida, atrás da sheet.

## Máquina de estados

### Composer

- `idle`: envio inicia um novo turno imediatamente.
- `executing + emptyQueue`: envio cria o primeiro item e revela o badge.
- `executing + queued`: envio acrescenta ao final e atualiza a contagem.
- `stopped`: a próxima mensagem inicia um novo turno.

### Item da fila

- `queued`: aguarda o término do turno atual.
- `promoting`: o operador escolheu `Enviar agora`; a execução atual está sendo
  interrompida de forma governada.
- `sending`: item promovido virou o próximo turno.
- `removed`: item retirado pelo operador e não será enviado.

Ao concluir naturalmente, o Atlas consome o primeiro item. Os demais continuam
na fila. Nenhuma mensagem desaparece silenciosamente.

## Protótipo HTML

A alteração inicial é limitada à proposta Codex. Ela deve demonstrar o fluxo
principal com interações reais no próprio arquivo:

1. escrever uma mensagem;
2. adicionar à fila;
3. revelar e atualizar `Na fila N`;
4. abrir a bottom sheet;
5. remover uma mensagem;
6. promover uma mensagem com `Enviar agora`;
7. fechar a sheet;
8. parar a execução.

Os dados são fixtures declaradas do protótipo; não devem ser apresentados como
telemetria real do Atlas. O HTML não cria backend, storage ou contratos Swift.

## Contrato futuro nativo

Uma implementação Swift posterior deve receber do model uma coleção estável,
sem colocar lógica de fila dentro da View:

```swift
struct QueuedFollowUp: Identifiable, Sendable, Equatable {
    let id: UUID
    var text: String
    let createdAt: Date
    var state: State
}
```

O model será responsável por persistência, ordenação, promoção, remoção e envio.
A View apenas renderiza e dispara intenções. Esta especificação não autoriza
alterar `ConversationModel` antes de um contrato Codex registrado no `OBRA.md`.

## Falhas e limites

- envio vazio não cria item;
- mensagens longas preservam conteúdo e refluem sem scroll horizontal;
- falha ao promover mantém a mensagem na fila e mostra recuperação acionável;
- cancelar a execução não apaga a fila;
- fechar a sheet não altera a fila;
- fila vazia fecha a sheet e remove o badge;
- nenhuma ação destrutiva acontece por gesto ambíguo.

## Verificação

- conferir visualmente os estados vazio, `Na fila 1` e múltiplas mensagens;
- verificar todas as ações com mouse/toque e teclado;
- validar foco, labels e ordem semântica;
- validar `prefers-reduced-motion`;
- validar 390 × 844 sem corte ou scroll horizontal;
- garantir que a V7 restante permaneça intacta;
- quando migrar ao app Swift, acrescentar golden checks do contrato e provar no
  iPhone físico antes de declarar a fila utilizável.

## Fora de escopo

- sincronização da fila entre dispositivos;
- envio offline;
- anexos dentro de mensagens enfileiradas;
- edição/reordenação por drag;
- implementação Swift nesta primeira etapa.
