import SwiftUI
import AtlasCore

// O motor de uma conversa: carrega mensagens da thread, envia uma nova interação
// e faz o STREAMING ao vivo da resposta (token a token) via AtlasCore. É o coração
// do Atlas AI no app — usa createAiInteraction + streamInteraction, já provados.

struct ChatBubble: Identifiable, Equatable {
    let id: String
    let role: String     // "user" | "assistant" | "system" | ...
    var text: String
    var streaming: Bool = false
}

@MainActor
@Observable
final class ConversationModel {
    var bubbles: [ChatBubble] = []
    var isSending = false
    var loadError: String?

    private let client: AtlasClient
    private(set) var threadId: String?

    init(client: AtlasClient, threadId: String?) {
        self.client = client
        self.threadId = threadId
    }

    func load() async {
        guard let threadId else { return }   // conversa nova: nada a carregar
        do {
            let response = try await client.getAiThread(threadId)
            bubbles = (response.thread.messages ?? [])
                .sorted { $0.position < $1.position }
                .map { ChatBubble(id: $0.id, role: $0.role, text: $0.content) }
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
            // captura a thread se foi criada agora, pra próximos envios
            if threadId == nil { threadId = created.trace.threadId }

            var live = ""
            let stream = await client.streamInteraction(traceId: created.trace.id)
            for try await frame in stream {
                switch frame {
                case .event(let e):
                    // ponytail: assume deltas incrementais em `content`; se o servidor
                    // mandar snapshot, trocar por `live = e.content`.
                    live += e.content
                    updateAssistant(assistantId, text: live, streaming: true)
                case .done:
                    updateAssistant(assistantId, text: live, streaming: false)
                case .error(let payload):
                    let msg = payload["message"]?.stringValue ?? "erro no stream"
                    updateAssistant(assistantId, text: live.isEmpty ? "⚠️ \(msg)" : live, streaming: false)
                case .ignored:
                    break
                }
            }
        } catch {
            updateAssistant(assistantId, text: "⚠️ \(error)", streaming: false)
        }
        isSending = false
    }

    private func updateAssistant(_ id: String, text: String, streaming: Bool) {
        guard let i = bubbles.firstIndex(where: { $0.id == id }) else { return }
        bubbles[i].text = text
        bubbles[i].streaming = streaming
    }
}
