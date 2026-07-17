import Foundation
import AtlasCore

/// Projeção de bolhas a partir do cache — peel de ConversationModel+ReadCache.
extension ConversationModel {
    static func bubbles(from messages: [AtlasAiMessage]) -> [ChatBubble] {
        messages.map { message in
            bubble(
                id: message.id,
                role: message.role,
                content: message.content,
                traceId: message.traceId,
                provider: message.provider,
                model: message.model,
                occurredAt: message.occurredAt
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
                model: message.model,
                occurredAt: message.occurredAt
            )
        }
    }

    static func bubble(
        id: String,
        role: String,
        content: String,
        traceId: String?,
        provider: String?,
        model: String?,
        occurredAt: String? = nil
    ) -> ChatBubble {
        let visible = role == "assistant"
            ? atlasVisibleAssistantText(content)
            : content
        return ChatBubble(
            id: id,
            role: role,
            text: visible ?? "A resposta anterior continha saída interna e foi ocultada.",
            traceId: traceId.map { TraceID($0) },
            occurredAt: occurredAt,
            provider: provider,
            model: model
        )
    }

    static func firstNewBubbleId(in bubbles: [ChatBubble], after visit: Date?) -> String? {
        guard let visit else { return nil }
        return bubbles.first { bubble in
            guard let occurred = AtlasTime.date(bubble.occurredAt) else { return false }
            return occurred > visit
        }?.id
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
                    model: $0.model,
                    occurredAt: $0.occurredAt
                )
            }
        )
    }
}
