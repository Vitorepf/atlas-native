import SwiftUI
import AtlasCore

// Motor de uma conversa: carrega mensagens, envia + STREAMING ao vivo, registra
// feedback governado, e — o diferencial vs Cursor — expõe a EXECUÇÃO agêntica ao
// vivo (a orquestra: quais agentes/providers/modelos, o estágio do Atlas Decide),
// via poll do trace durante o turno.

struct ExecAgent: Equatable, Identifiable {
    let id: String
    let agent: String?     // orquestrador / atlas / …
    let provider: String?  // hermes_cli / claude_cli / …
    let model: String?     // claude-sonnet-4-6 / qwen3.6-27b / …
    let status: String     // queued / processing / succeeded / failed / …
}

struct ChatBubble: Identifiable, Equatable {
    let id: String
    let role: String
    var text: String
    var streaming: Bool = false
    var traceId: String? = nil
    var provider: String? = nil
    var model: String? = nil
    var feedbackAction: String? = nil
    // Execução ao vivo (a orquestra)
    var startedAt: Date? = nil
    var elapsedMs: Int? = nil
    var agents: [ExecAgent] = []
    var decideStage: String? = nil
    var decideStrategy: String? = nil
}

enum FeedbackKind: String, CaseIterable, Identifiable {
    case util, contexto, longo, fraco
    var id: String { rawValue }
    var label: String {
        switch self {
        case .util: return "útil"; case .contexto: return "contexto"
        case .longo: return "longo"; case .fraco: return "fraco"
        }
    }
    var payload: FeedbackAiInteractionInput {
        switch self {
        case .util: return .init(feedbackScore: 5, feedbackAction: "useful")
        case .contexto: return .init(feedbackScore: 1, feedbackAction: "wrong_context")
        case .longo: return .init(feedbackScore: 2, feedbackComment: "[too_long]")
        case .fraco: return .init(feedbackScore: 1, feedbackComment: "[weak]")
        }
    }
    var activeAction: String {
        switch self {
        case .util: return "useful"; case .contexto: return "wrong_context"
        case .longo: return "too_long"; case .fraco: return "weak"
        }
    }
}

@MainActor
@Observable
final class ConversationModel {
    var bubbles: [ChatBubble] = []
    var isSending = false
    var loadError: String?
    var toast: String?

    private let client: AtlasClient
    private(set) var threadId: String?
    private var poll: Task<Void, Never>?
    private var stream: Task<Void, Never>?

    init(client: AtlasClient, threadId: String?) {
        self.client = client
        self.threadId = threadId
    }

    func load() async {
        guard let threadId else { return }
        do {
            let response = try await client.getAiThread(threadId)
            bubbles = (response.thread.messages ?? [])
                .sorted { $0.position < $1.position }
                .map { ChatBubble(id: $0.id, role: $0.role, text: $0.content,
                                  traceId: $0.traceId, provider: $0.provider, model: $0.model) }
        } catch {
            loadError = String(describing: error)
        }
    }

    func send(_ text: String) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isSending else { return }
        isSending = true

        bubbles.append(ChatBubble(id: "local-user-\(bubbles.count)", role: "user", text: trimmed))
        let aid = "local-assistant-\(bubbles.count)"
        bubbles.append(ChatBubble(id: aid, role: "assistant", text: "", streaming: true, startedAt: Date()))

        do {
            let input = CreateAiInteractionInput(inputText: trimmed, threadId: threadId,
                                                 newThread: threadId == nil ? true : nil)
            let created = try await client.createAiInteraction(input)
            if threadId == nil { threadId = created.trace.threadId }
            let traceId = created.trace.id
            update(aid) { $0.traceId = traceId; $0.provider = created.trace.provider }

            // Poll da execução (a orquestra) em paralelo ao stream de conteúdo.
            poll = Task { [weak self] in
                while !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: 1_300_000_000)
                    guard let self, !Task.isCancelled else { break }
                    guard let resp = try? await self.client.getAiInteraction(traceId) else { continue }
                    self.applyExecution(aid, resp.trace)
                    if ["succeeded", "failed", "cancelled"].contains(resp.trace.status) { break }
                }
            }

            var live = ""
            for try await frame in await client.streamInteraction(traceId: traceId) {
                switch frame {
                case .event(let e): live += e.content; update(aid) { $0.text = live; $0.streaming = true }
                case .done: break
                case .error(let p):
                    let m = p["message"]?.stringValue ?? "erro no stream"
                    update(aid) { $0.text = live.isEmpty ? "⚠️ \(m)" : live }
                case .ignored: break
                }
            }
            poll?.cancel()
            finalize(aid, traceId: traceId)
        } catch {
            update(aid) { $0.text = "⚠️ \(error)"; $0.streaming = false }
        }
        isSending = false
    }

    func cancel() {
        poll?.cancel(); stream?.cancel()
        for i in bubbles.indices where bubbles[i].streaming { bubbles[i].streaming = false }
        isSending = false
        toast = "cancelado"
    }

    func feedback(_ bubbleId: String, _ kind: FeedbackKind) async {
        guard let i = bubbles.firstIndex(where: { $0.id == bubbleId }), let trace = bubbles[i].traceId else { return }
        let previous = bubbles[i].feedbackAction
        bubbles[i].feedbackAction = kind.activeAction
        do {
            _ = try await client.feedbackAiInteraction(trace, feedback: kind.payload)
            toast = "\(kind.label) registrado"
        } catch {
            bubbles[i].feedbackAction = previous
            toast = "feedback falhou"
        }
    }

    // MARK: - Execução

    private func applyExecution(_ id: String, _ trace: AtlasAiTrace) {
        let agents = (trace.jobs ?? []).map {
            ExecAgent(id: $0.id, agent: $0.agentSlug, provider: $0.provider, model: $0.model, status: $0.status)
        }
        update(id) {
            $0.agents = agents
            $0.decideStrategy = trace.atlasDecideExecution?.strategy
            $0.decideStage = trace.atlasDecideExecution?.atlasDecideStage
        }
    }

    private func finalize(_ id: String, traceId: String) {
        Task { [weak self] in
            guard let self else { return }
            let final = try? await self.client.getAiInteraction(traceId)
            self.update(id) {
                $0.streaming = false
                $0.agents = []
                $0.decideStage = nil
                if let t = final?.trace {
                    $0.model = t.model ?? $0.model
                    $0.elapsedMs = t.latencyMs ?? $0.startedAt.map { Int(Date().timeIntervalSince($0) * 1000) }
                }
            }
        }
    }

    private func update(_ id: String, _ mutate: (inout ChatBubble) -> Void) {
        guard let i = bubbles.firstIndex(where: { $0.id == id }) else { return }
        mutate(&bubbles[i])
    }
}
