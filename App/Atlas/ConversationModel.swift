import SwiftUI
import AtlasCore
import AtlasImaging

@MainActor
@Observable
final class ConversationModel {
    static let effortPreferenceKey = "atlas.composer.effort"
    static let draftPrefix = "atlas.conversation.draft."
    static let visitedPrefix = "atlas.conversation.lastVisit."

    var bubbles: [ChatBubble] = []
    var isSending = false
    var loadError: String?
    /// Tipo de falha do load da thread (espelha `AtlasSession.failureKind`).
    /// A casca distingue offline × timeout × recusada — não só a string genérica.
    var loadFailureKind: AtlasNetworkFailureKind?
    var toast: String?
    var cacheCapturedAt: Date?
    var showingStaleCache = false
    // Workspace da conversa — entra no payload do create (workspace_slug/name/path,
    // padrão do mobile RN; o servidor lê payload.workspace_* no AiGateway/AWIS).
    var workspaceName: String?
    var workspaceSlug: String?
    var workspacePath: String?
    // Anexos do próximo envio + progresso agregado do upload (0…1, nil = ocioso)
    var drafts: [LocalDraft] = []
    var uploadPercent: Double?
    /// Follow-ups enviados durante um turno. A casca mostra esta lista como
    /// `Fila N`; a persistência/FIFO vivem no Core, não na View.
    var queuedMessages: [QueuedMessage] = []
    /// Preferência persistente pertence ao model; a View só renderiza/cicla.
    var effort: AtlasComputeEffort
    /// Rascunho persistido por thread. Conversa nova usa escopo local até o
    /// servidor devolver `threadId`, quando o model migra o texto para a chave
    /// canônica da thread.
    var draftText: String = ""
    /// Marcador calculado ao abrir: primeiro turno posterior à visita anterior.
    var firstNewBubbleId: String?
    var lastVisitAt: Date?
    /// Artefatos, diff e decisões de revisão vivem num domínio dedicado. A
    /// conversa só recebe de volta o trace atualizado para refrescar as bolhas.
    let reviews: ChangeReviewModel
    /// Último recibo de continuidade. A View pode projetá-lo, mas nunca cria
    /// sessão/local history por conta própria para simular o handoff.
    var latestSurfaceHandoff: AtlasAiSurfaceHandoff?
    /// Último recibo de steering da execução. Aceite e rejeição vêm do servidor;
    /// a casca não infere se uma instrução entrou na fila do checkpoint seguro.
    var lastSteerReceipt: AtlasInteractionSteerResponse?

    /// Fatos determinísticos coletados por turno e prefixados à pergunta NO FIO.
    /// A bolha do operador continua sendo o que ele escreveu — mesma lei do
    /// `AtlasLongMessage`: o que se transporta não é o que se mostra.
    ///
    /// É isto que torna o card do Código uma conversa ANCORADA em vez de um
    /// chat que opina: quem lê o git é o determinístico, quem entende é o
    /// agente. `nil` (ausente ou devolvendo nil) = conversa normal, sem muleta.
    @ObservationIgnored var turnFacts: ((String) async -> String?)?

    /// A natureza da tarefa, DECLARADA pela superfície (`payload.task_type`).
    ///
    /// O Atlas Decide precisa saber se é código para escolher o motor, e sem
    /// isto ele adivinha farejando palavra na prosa (`hasProgrammingIntentSignal`
    /// procura "repo", "commit"…). Duas consequências ruins: numa conversa sobre
    /// a vida, citar "commit" viraria tarefa de código; e no card do Código —
    /// que é uma tela inteira sobre um repositório — quem acabava decidindo era
    /// o dossiê de fatos que a própria máquina prefixou. A tela SABE o que ela
    /// é; adivinhar o que já se sabe é o desperdício mais bobo de todos.
    @ObservationIgnored var taskKind: String?

    let client: AtlasClient
    /// Module-visible so `ConversationModel+Send` can adopt canonical thread.
    var threadId: ThreadID?
    /// Visível às extensions `+Queue` / `+Execution` (mesmo módulo).
    var activeRun: InteractionRun?
    /// Module-visible so `ConversationModel+Attachments` can mutate drafts.
    var attachmentInputs: [String: AttachmentInput] = [:]
    @ObservationIgnored var pendingAttachmentPreparations: [String: PendingAttachmentPreparation] = [:]
    /// Module-visible so `ConversationModel+Send` can upload before create.
    @ObservationIgnored let engine: AtlasRichInputEngine
    /// Module-visible so `ConversationModel+Send` can execute/recover outbox.
    @ObservationIgnored let outbox: InteractionOutbox
    @ObservationIgnored let queueStore: QueuedFollowUpStore
    @ObservationIgnored let readCache: ThreadReadCache
    @ObservationIgnored var queueScope: String
    @ObservationIgnored var draftScope: String
}
