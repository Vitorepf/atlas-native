import SwiftUI
import AtlasCore
import AtlasImaging

@MainActor
@Observable
final class ConversationModel {
    private static let effortPreferenceKey = "atlas.composer.effort"
    private static let draftPrefix = "atlas.conversation.draft."
    private static let visitedPrefix = "atlas.conversation.lastVisit."

    /// Module-visible so `ConversationModel+Attachments` can own preparation.
    struct PendingAttachmentPreparation {
        let kind: AtlasAttachmentKind
        let task: Task<Void, Never>
    }

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

    /// Identidade da execução atual exposta à ponte ActivityKit, nunca à View.
    /// `nil` até o servidor confirmar o trace continua sendo um estado normal.
    var currentStreamingTraceId: TraceID? {
        bubbles.last(where: { $0.streaming && $0.traceId != nil })?.traceId
    }

    init(
        client: AtlasClient,
        threadId: ThreadID?,
        readCache: ThreadReadCache = ThreadReadCache(fileURL: ThreadReadCache.applicationSupportFileURL())
    ) {
        self.client = client
        self.reviews = ChangeReviewModel(client: client)
        self.threadId = threadId
        self.engine = AtlasRichInputEngine(transport: client, installSalt: AtlasInstallationIdentity.id)
        self.outbox = InteractionOutbox(fileURL: InteractionOutbox.applicationSupportFileURL())
        self.queueStore = QueuedFollowUpStore(fileURL: QueuedFollowUpStore.applicationSupportFileURL())
        self.readCache = readCache
        self.queueScope = threadId.map { "thread:\($0.rawValue)" } ?? "local:\(UUID().uuidString.lowercased())"
        self.draftScope = self.queueScope
        self.effort = AtlasComputeEffort(
            rawValue: UserDefaults.standard.string(forKey: Self.effortPreferenceKey) ?? ""
        ) ?? .auto
        self.draftText = Self.loadDraft(scope: draftScope)
        if let threadId {
            self.lastVisitAt = Self.lastVisitDate(threadId: threadId.rawValue)
        }
        self.reviews.onTraceUpdated = { [weak self] traceId, trace in
            guard let self else { return }
            for bubble in self.bubbles where bubble.traceId == traceId {
                self.applyExecution(bubble.id, trace)
            }
        }
    }

    func cycleEffort() {
        effort = effort.next
        UserDefaults.standard.set(effort.rawValue, forKey: Self.effortPreferenceKey)
    }

    func updateDraft(_ value: String) {
        draftText = value
        Self.saveDraft(value, scope: draftScope)
    }

    func markThreadVisited() {
        guard let threadId else { return }
        Self.markVisited(threadId: threadId.rawValue)
    }

    static func lastVisitDate(threadId: String) -> Date? {
        UserDefaults.standard.object(forKey: visitedPrefix + threadId) as? Date
    }

    static func hasNewerContent(_ thread: AtlasAiThread) -> Bool {
        guard let last = AtlasTime.date(thread.lastMessageAt ?? thread.updatedAt) else { return false }
        guard let visit = lastVisitDate(threadId: thread.id) else { return thread.messageCount > 0 }
        return last > visit
    }

    static func loadDraft(scope: String) -> String {
        UserDefaults.standard.string(forKey: draftPrefix + scope) ?? ""
    }

    static func saveDraft(_ value: String, scope: String) {
        let key = draftPrefix + scope
        if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            UserDefaults.standard.removeObject(forKey: key)
        } else {
            UserDefaults.standard.set(value, forKey: key)
        }
    }

    private static func markVisited(threadId: String) {
        UserDefaults.standard.set(Date(), forKey: visitedPrefix + threadId)
    }

    func load() async {
        await loadQueuedMessages()
        if let threadId {
            let hydratedFromCache = await hydrateFromCache(threadId: threadId)
            do {
                let response = try await client.getAiThread(threadId.rawValue)
                applyWorkspace(response.thread.workspace)
                let messages = (response.thread.messages ?? []).sorted { $0.position < $1.position }
                let previousVisit = lastVisitAt
                bubbles = Self.bubbles(from: messages)
                firstNewBubbleId = Self.firstNewBubbleId(in: bubbles, after: previousVisit)
                showingStaleCache = false
                cacheCapturedAt = nil
                loadError = nil
                loadFailureKind = nil
                try? await readCache.save(snapshot: Self.snapshot(
                    threadId: threadId.rawValue,
                    workspacePath: response.thread.workspace,
                    messages: messages
                ))
                await loadExecutionHistory()
            } catch {
                if hydratedFromCache || showingStaleCache {
                    toast = "Sem rede agora — mantendo a última leitura salva."
                } else if bubbles.isEmpty {
                    loadError = atlasUserMessage(for: error)
                    loadFailureKind = atlasNetworkFailureKind(for: error)
                }
            }
        }
        await recoverPendingIfNeeded()
    }

    func send(_ text: String, effort: AtlasComputeEffort = .auto) async {
        updateDraft("")
        _ = await sendTurn(text, effort: effort, drainQueueOnSuccess: true)
    }

    func cancel() {
        let run = activeRun
        let activeTraces = bubbles.compactMap { bubble -> (id: String, traceId: TraceID)? in
            guard bubble.streaming, let traceId = bubble.traceId else { return nil }
            return (bubble.id, traceId)
        }
        for i in bubbles.indices where bubbles[i].streaming { bubbles[i].streaming = false }
        isSending = false
        toast = "encerrando sessão…"
        Task {
            await run?.cancel()

            var confirmed = false
            for activeTrace in activeTraces {
                guard let refreshed = try? await client.getAiInteraction(activeTrace.traceId) else { continue }
                applyExecution(activeTrace.id, refreshed.trace)
                confirmed = confirmed || refreshed.trace.turnStatus == .cancelled
            }

            toast = confirmed ? "sessão encerrada" : "cancelamento solicitado"
        }
    }

    func feedback(_ bubbleId: String, _ kind: FeedbackKind) async {
        guard let i = bubbles.firstIndex(where: { $0.id == bubbleId }), let trace = bubbles[i].traceId else { return }
        let previous = bubbles[i].feedbackAction
        bubbles[i].feedbackAction = kind.activeAction
        do {
            _ = try await client.feedbackAiInteraction(trace.rawValue, feedback: kind.payload)
            toast = "\(kind.label) registrado"
        } catch {
            bubbles[i].feedbackAction = previous
            toast = "feedback falhou"
        }
    }

    func update(_ id: String, _ mutate: (inout ChatBubble) -> Void) {
        guard let i = bubbles.firstIndex(where: { $0.id == id }) else { return }
        mutate(&bubbles[i])
    }

}
