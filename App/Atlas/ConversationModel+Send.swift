import SwiftUI
import AtlasCore
import AtlasImaging

/// Envio de turno — fora do arquivo principal para ConversationModel ficar sob a régua (<550).
@MainActor
extension ConversationModel {
    @discardableResult
    func sendTurn(
        _ text: String,
        effort: AtlasComputeEffort,
        drainQueueOnSuccess: Bool,
        queuedMessageId: QueuedMessage.ID? = nil
    ) async -> Bool {
        var trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if isSending || activeRun != nil {
            await queue(text: trimmed)
            return false
        }

        await finishPendingAttachmentPreparations()
        let sendingDrafts = drafts
        if trimmed.isEmpty && !sendingDrafts.isEmpty {
            trimmed = "analise \(sendingDrafts.count == 1 ? "o anexo enviado" : "os \(sendingDrafts.count) anexos enviados")"
        }
        guard !trimmed.isEmpty else { return false }

        let originalText = trimmed
        let existingTextFiles = sendingDrafts.filter { $0.kind == .text || $0.kind == .code }.count
        let longMessage: AtlasPreparedLongMessage
        do {
            longMessage = try AtlasLongMessage.prepare(
                originalText, existingTextFileCount: existingTextFiles
            )
        } catch {
            toast = String(describing: error)
            return false
        }
        trimmed = longMessage.inputText
        isSending = true

        bubbles.append(ChatBubble(id: "local-user-\(bubbles.count)", role: "user", text: originalText))
        let aid = "local-assistant-\(bubbles.count)"
        bubbles.append(ChatBubble(id: aid, role: "assistant", text: "", streaming: true, startedAt: Date()))

        var fields: RichInputInteractionFields? = nil
        if !sendingDrafts.isEmpty || longMessage.attachment != nil {
            guard let uploaded = await uploadForSendTurn(
                sendingDrafts: sendingDrafts,
                longMessage: longMessage,
                trimmed: trimmed,
                assistantId: aid
            ) else { return false }
            fields = uploaded
        }

        var completedSuccessfully = false
        do {
            let input = await buildSendTurnInput(
                originalText: originalText,
                trimmed: trimmed,
                effort: effort,
                longMessage: longMessage,
                fields: fields
            )
            completedSuccessfully = try await execute(
                input,
                assistantId: aid,
                queuedMessageId: queuedMessageId
            )
        } catch {
            apply(error, to: aid)
        }
        activeRun = nil
        isSending = false
        if completedSuccessfully && drainQueueOnSuccess {
            await drainQueuedMessages()
        }
        return completedSuccessfully
    }
}
