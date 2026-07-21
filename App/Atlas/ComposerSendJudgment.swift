import Foundation
import AtlasCore

// MARK: - Types

/// Exclusive composer send readiness face (WAVE-046).
enum ComposerSendFace: Equatable {
    case empty
    case ready
    case blockedFailed
    case blockedUploading
    case queueOnly
    case executing

    var productWord: String {
        switch self {
        case .empty: return "empty"
        case .ready: return "ready"
        case .blockedFailed: return "blocked_failed"
        case .blockedUploading: return "blocked_uploading"
        case .queueOnly: return "queue_only"
        case .executing: return "executing"
        }
    }

    /// Gold CTA / queue submit allowed.
    var allowsSend: Bool {
        switch self {
        case .ready, .queueOnly: return true
        case .empty, .blockedFailed, .blockedUploading, .executing: return false
        }
    }

    var spokenLabel: String {
        switch self {
        case .empty:
            return "enviar indisponível, sem mensagem nem anexo"
        case .ready:
            return "enviar ao Atlas"
        case .blockedFailed:
            return "enviar indisponível, anexo falhou"
        case .blockedUploading:
            return "enviar indisponível, anexo ainda subindo"
        case .queueOnly:
            return "adicionar à fila"
        case .executing:
            return "enviar indisponível, Atlas processando"
        }
    }

    var spokenHint: String {
        switch self {
        case .empty:
            return "escreva uma mensagem ou adicione um anexo para enviar"
        case .ready:
            return "envia mensagem e anexos ao Atlas"
        case .blockedFailed:
            return "toque no anexo com falha para ver o erro, ou remova-o antes de enviar"
        case .blockedUploading:
            return "aguarde o anexo terminar de subir antes de enviar"
        case .queueOnly:
            return "envia esta mensagem na fila do próximo turno"
        case .executing:
            return "escreva uma mensagem para adicionar à fila durante a execução"
        }
    }
}

// MARK: - Judgment

/// Pure send-readiness grammar — face · allowsSend · draft rank · spoken.
enum ComposerSendJudgment {

    static func hasText(_ draftText: String) -> Bool {
        !draftText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    static func hasFailedDraft(_ drafts: [LocalDraft]) -> Bool {
        ComposerDraftJudgment.hasFailed(drafts)
    }

    static func hasUploadingDraft(_ drafts: [LocalDraft]) -> Bool {
        ComposerDraftJudgment.hasUploading(drafts)
    }

    static func hasReadyDraft(_ drafts: [LocalDraft]) -> Bool {
        drafts.contains {
            if case .pronto = $0.state { return true }
            return false
        }
    }

    /// WAVE-086: rank owned by Draft judgment (failed-first).
    static func rankDrafts(_ drafts: [LocalDraft]) -> [LocalDraft] {
        ComposerDraftJudgment.rankDrafts(drafts)
    }

    static func draftAttentionRank(_ draft: LocalDraft) -> Int {
        ComposerDraftJudgment.draftAttentionRank(draft)
    }

    static func face(
        draftText: String,
        drafts: [LocalDraft],
        isSending: Bool,
        liveBubblePresent: Bool
    ) -> ComposerSendFace {
        let executing = isSending || liveBubblePresent
        let text = hasText(draftText)

        if executing {
            return text ? .queueOnly : .executing
        }

        if hasFailedDraft(drafts) {
            return .blockedFailed
        }
        if hasUploadingDraft(drafts) {
            // Uploading without ready payload → blocked; text alone still waits
            // for attachments to finish so CTA does not lie "send ready".
            return .blockedUploading
        }

        if text || hasReadyDraft(drafts) {
            return .ready
        }
        // Drafts present but none pronto (should not happen without subindo/falhou).
        if !drafts.isEmpty {
            return .blockedUploading
        }
        return .empty
    }

    @MainActor
    static func face(model: ConversationModel, liveBubblePresent: Bool) -> ComposerSendFace {
        face(
            draftText: model.draftText,
            drafts: model.drafts,
            isSending: model.isSending,
            liveBubblePresent: liveBubblePresent
        )
    }

    // MARK: Send chrome spoken (IDLE)

    static func spokenSendChrome(processing: String, sendSpoken: String) -> String {
        "\(processing), \(sendSpoken)"
    }

}
