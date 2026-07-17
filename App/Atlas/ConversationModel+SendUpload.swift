import SwiftUI
import AtlasCore
import AtlasImaging

@MainActor
extension ConversationModel {
    /// Upload dos anexos ANTES do create (chunked + resume + sha via engine).
    /// Retorna `nil` em falha — já aplica erro na bolha assistente.
    func uploadForSendTurn(
        sendingDrafts: [LocalDraft],
        longMessage: AtlasPreparedLongMessage,
        trimmed: String,
        assistantId: String
    ) async -> RichInputInteractionFields? {
        guard !sendingDrafts.isEmpty || longMessage.attachment != nil else { return nil }

        for i in drafts.indices { drafts[i].state = .subindo }
        do {
            var inputs = sendingDrafts.compactMap { attachmentInputs[$0.id] }
            if let attachment = longMessage.attachment { inputs.append(attachment) }
            let images = inputs.filter { $0.kind == .image }
            let documents = inputs.filter { $0.kind != .image }
            let uploaded = try await engine.uploadAll(
                images: images, documents: documents,
                progress: { [weak self] p in
                    Task { @MainActor [weak self] in
                        self?.uploadPercent = p.phase == .complete ? nil : p.percent
                    }
                })
            let fields = engine.interactionFields(images: uploaded.images,
                                                  documents: uploaded.documents,
                                                  inputText: trimmed)
            drafts.removeAll(); attachmentInputs.removeAll()
            uploadPercent = nil
            return fields
        } catch {
            for i in drafts.indices { drafts[i].state = .falhou("\(error)") }
            uploadPercent = nil
            update(assistantId) { $0.text = "⚠️ upload falhou: \(error)"; $0.streaming = false }
            isSending = false
            return nil
        }
    }
}
