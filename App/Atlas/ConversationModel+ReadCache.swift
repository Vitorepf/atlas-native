import Foundation
import AtlasCore

/// F6.1: hidratação/persistência do snapshot de leitura — fora do arquivo
/// principal para ConversationModel ficar sob a régua (<800).
extension ConversationModel {
    func hydrateFromCache(threadId: ThreadID) async -> Bool {
        guard let snapshot = await readCache.load(threadId: threadId.rawValue) else {
            showingStaleCache = false
            cacheCapturedAt = nil
            return false
        }
        applyWorkspace(snapshot.workspacePath)
        bubbles = Self.bubbles(from: snapshot.messages)
        cacheCapturedAt = snapshot.capturedAt
        showingStaleCache = true
        loadError = nil
        return true
    }

    func applyWorkspace(_ path: String?) {
        guard let path, !path.isEmpty else { return }
        workspacePath = path
        workspaceName = (path as NSString).lastPathComponent
        workspaceSlug = workspaceName?.lowercased()
    }

    static func bubbles(from messages: [AtlasAiMessage]) -> [ChatBubble] {
        messages.map { message in
            bubble(
                id: message.id,
                role: message.role,
                content: message.content,
                traceId: message.traceId,
                provider: message.provider,
                model: message.model
            )
        }
    }

    static func bubbles(from messages: [ThreadReadCache.Message]) -> [ChatBubble] {
        messages.map { message in
            bubble(
                id: message.id,
                role: message.role,
                content: message.content,
                traceId: message.traceId,
                provider: message.provider,
                model: message.model
            )
        }
    }

    static func bubble(
        id: String,
        role: String,
        content: String,
        traceId: String?,
        provider: String?,
        model: String?
    ) -> ChatBubble {
        let visible = role == "assistant"
            ? atlasVisibleAssistantText(content)
            : content
        return ChatBubble(
            id: id,
            role: role,
            text: visible ?? "A resposta anterior continha saída interna e foi ocultada.",
            traceId: traceId.map { TraceID($0) },
            provider: provider,
            model: model
        )
    }

    static func snapshot(
        threadId: String,
        workspacePath: String?,
        messages: [AtlasAiMessage]
    ) -> ThreadReadCache.Snapshot {
        ThreadReadCache.Snapshot(
            threadId: threadId,
            capturedAt: Date(),
            workspacePath: workspacePath,
            messages: messages.map {
                ThreadReadCache.Message(
                    id: $0.id,
                    role: $0.role,
                    content: $0.content,
                    traceId: $0.traceId,
                    provider: $0.provider,
                    model: $0.model
                )
            }
        )
    }
}
