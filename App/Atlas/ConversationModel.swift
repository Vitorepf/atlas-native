import SwiftUI
import AtlasCore

// O motor de uma conversa: carrega mensagens, envia e faz STREAMING ao vivo da
// resposta, e registra feedback governado por turno (feedbackAiInteraction).

struct ChatBubble: Identifiable, Equatable {
    let id: String
    let role: String            // "user" | "assistant" | ...
    var text: String
    var streaming: Bool = false
    var traceId: String? = nil  // pra feedback + proveniência
    var provider: String? = nil // pra a assinatura "— claude"
    var feedbackAction: String? = nil // estado ativo do feedback
}

// Feedback dirigido — treina o roteamento em vez de sumir no vácuo.
enum FeedbackKind: String, CaseIterable, Identifiable {
    case util, contexto, longo, fraco
    var id: String { rawValue }
    var label: String {
        switch self {
        case .util: return "útil"
        case .contexto: return "contexto"
        case .longo: return "longo"
        case .fraco: return "fraco"
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
    var activeAction: String {  // como o servidor devolve o estado ativo
        switch self {
        case .util: return "useful"
        case .contexto: return "wrong_context"
        case .longo: return "too_long"
        case .fraco: return "weak"
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
                                  traceId: $0.traceId, provider: $0.provider) }
        } catch {
            loadError = String(describing: error)
        }
    }

    func send(_ text: String) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isSending else { return }
        isSending = true

        bubbles.append(ChatBubble(id: "local-user-\(bubbles.count)", role: "user", text: trimmed))
        let assistantId = "local-assistant-\(bubbles.count)"
        bubbles.append(ChatBubble(id: assistantId, role: "assistant", text: "", streaming: true))

        do {
            let input = CreateAiInteractionInput(
                inputText: trimmed,
                threadId: threadId,
                newThread: threadId == nil ? true : nil
            )
            let created = try await client.createAiInteraction(input)
            if threadId == nil { threadId = created.trace.threadId }
            update(assistantId) { $0.traceId = created.trace.id; $0.provider = created.trace.provider }

            var live = ""
            let stream = await client.streamInteraction(traceId: created.trace.id)
            for try await frame in stream {
                switch frame {
                case .event(let e):
                    live += e.content
                    update(assistantId) { $0.text = live; $0.streaming = true }
                case .done:
                    update(assistantId) { $0.streaming = false }
                case .error(let payload):
                    let msg = payload["message"]?.stringValue ?? "erro no stream"
                    update(assistantId) { $0.text = live.isEmpty ? "⚠️ \(msg)" : live; $0.streaming = false }
                case .ignored:
                    break
                }
            }
        } catch {
            update(assistantId) { $0.text = "⚠️ \(error)"; $0.streaming = false }
        }
        isSending = false
    }

    func feedback(_ bubbleId: String, _ kind: FeedbackKind) async {
        guard let i = bubbles.firstIndex(where: { $0.id == bubbleId }), let trace = bubbles[i].traceId else { return }
        let previous = bubbles[i].feedbackAction
        bubbles[i].feedbackAction = kind.activeAction     // otimista
        do {
            _ = try await client.feedbackAiInteraction(trace, feedback: kind.payload)
            toast = "\(kind.label) registrado"
        } catch {
            bubbles[i].feedbackAction = previous
            toast = "feedback falhou"
        }
    }

    private func update(_ id: String, _ mutate: (inout ChatBubble) -> Void) {
        guard let i = bubbles.firstIndex(where: { $0.id == id }) else { return }
        mutate(&bubbles[i])
    }
}
