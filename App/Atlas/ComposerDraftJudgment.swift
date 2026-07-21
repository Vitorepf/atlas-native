import Foundation
import AtlasCore

// MARK: - Types

/// Exclusive composer attachment-strip face (WAVE-086).
enum ComposerDraftStripFace: Equatable {
    case silence
    case drafts(Int)
    case uploading
    case failedPresent

    var productWord: String {
        switch self {
        case .silence: return "silence"
        case .drafts(let n): return "drafts(\(n))"
        case .uploading: return "uploading"
        case .failedPresent: return "failed_present"
        }
    }

    var spokenFace: String {
        switch self {
        case .silence:
            return "sem anexos"
        case .drafts(let n):
            let noun = n == 1 ? "anexo" : "anexos"
            return "\(n) \(noun) no composer"
        case .uploading:
            return "anexo subindo"
        case .failedPresent:
            return "anexo com falha"
        }
    }
}

/// Exclusive draft thumb state face (WAVE-086).
enum ComposerDraftThumbFace: Equatable {
    case pronto
    case subindo
    case falhou

    var productWord: String {
        switch self {
        case .pronto: return "pronto"
        case .subindo: return "subindo"
        case .falhou: return "falhou"
        }
    }

    var spokenFace: String {
        switch self {
        case .pronto: return "pronto para enviar"
        case .subindo: return "enviando"
        case .falhou: return "falhou"
        }
    }
}

// MARK: - Judgment

/// Pure draft/attachment grammar — strip · thumb · rank · spoken · pack.
/// WAVE-046 send face stays exclusive for CTA; this organ is strip/thumb only.
enum ComposerDraftJudgment {

    static let removeHint = "remove este anexo antes do envio"
    static let failedHint = "toque para ver o erro completo no aviso"

    // MARK: Rank (failed-first · shared with Send)

    /// 0 failed · 1 uploading · 2 pronto · 3 other
    static func draftAttentionRank(_ draft: LocalDraft) -> Int {
        switch draft.state {
        case .falhou: return 0
        case .subindo: return 1
        case .pronto: return 2
        }
    }

    static func rankDrafts(_ drafts: [LocalDraft]) -> [LocalDraft] {
        drafts.enumerated().sorted { lhs, rhs in
            let lr = draftAttentionRank(lhs.element)
            let rr = draftAttentionRank(rhs.element)
            if lr != rr { return lr < rr }
            return lhs.offset < rhs.offset
        }.map(\.element)
    }

    static func hasFailed(_ drafts: [LocalDraft]) -> Bool {
        drafts.contains {
            if case .falhou = $0.state { return true }
            return false
        }
    }

    static func hasUploading(_ drafts: [LocalDraft]) -> Bool {
        drafts.contains {
            if case .subindo = $0.state { return true }
            return false
        }
    }

    // MARK: Faces

    static func stripFace(
        drafts: [LocalDraft],
        uploadPercent: Double?
    ) -> ComposerDraftStripFace {
        if hasFailed(drafts) { return .failedPresent }
        if hasUploading(drafts) || uploadPercent != nil { return .uploading }
        if drafts.isEmpty { return .silence }
        return .drafts(drafts.count)
    }

    static func thumbFace(_ draft: LocalDraft) -> ComposerDraftThumbFace {
        switch draft.state {
        case .pronto: return .pronto
        case .subindo: return .subindo
        case .falhou: return .falhou
        }
    }

    static func isStripVisible(drafts: [LocalDraft], uploadPercent: Double?) -> Bool {
        stripFace(drafts: drafts, uploadPercent: uploadPercent) != .silence
            || uploadPercent != nil
            || !drafts.isEmpty
    }

    // MARK: Spoken

    static func spokenStrip(drafts: [LocalDraft], uploadPercent: Double?) -> String {
        let face = stripFace(drafts: drafts, uploadPercent: uploadPercent)
        var parts = [face.spokenFace]
        if let p = uploadPercent {
            parts.append(spokenUploadPercent(p))
        }
        return parts.joined(separator: ", ")
    }

    static func spokenUploadPercent(_ percent: Double) -> String {
        let clamped = max(0, min(1, percent))
        return "enviando anexos, \(Int(clamped * 100)) por cento"
    }

    static func spokenThumb(_ draft: LocalDraft) -> String {
        let noun = draft.kind == .image ? "imagem" : "arquivo"
        var parts = ["anexo \(noun) \(draft.fileName)"]
        parts.append(contentsOf: spokenThumbSizeParts(draft))
        parts.append(contentsOf: spokenThumbStateParts(draft))
        return parts.joined(separator: ", ")
    }

    static func spokenThumbSizeParts(_ draft: LocalDraft) -> [String] {
        guard draft.bytes > 0 else { return [] }
        let mb = String(format: "%.1f", Double(draft.bytes) / 1_048_576)
        return ["\(mb) megabytes"]
    }

    static func spokenThumbStateParts(_ draft: LocalDraft) -> [String] {
        let face = thumbFace(draft)
        switch face {
        case .pronto, .subindo:
            return [face.spokenFace]
        case .falhou:
            if case .falhou(let message) = draft.state {
                var parts = [face.spokenFace]
                if !message.isEmpty { parts.append(message) }
                return parts
            }
            return [face.spokenFace]
        }
    }

    static func spokenRemove(_ draft: LocalDraft) -> String {
        "remover anexo \(draft.fileName)"
    }

    static func spokenFailedValue(_ message: String) -> String {
        message.isEmpty ? "erro no envio" : message
    }

    // MARK: Pack

    static func packFacts(
        drafts: [LocalDraft],
        uploadPercent: Double?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = stripFace(drafts: drafts, uploadPercent: uploadPercent)
        facts.append("draft_strip_face: \(face.productWord)")
        facts.append("draft_count: \(drafts.count)")
        let failed = drafts.filter {
            if case .falhou = $0.state { return true }
            return false
        }.count
        let uploading = drafts.filter {
            if case .subindo = $0.state { return true }
            return false
        }.count
        let ready = drafts.filter {
            if case .pronto = $0.state { return true }
            return false
        }.count
        facts.append("draft_failed: \(failed)")
        facts.append("draft_uploading: \(uploading)")
        facts.append("draft_ready: \(ready)")
        if let p = uploadPercent {
            facts.append("draft_upload_percent: \(Int(max(0, min(1, p)) * 100))")
        } else {
            absences.append("upload percent não publicado")
        }
        if drafts.isEmpty {
            absences.append("nenhum anexo no composer")
        }
        return (facts, absences)
    }

    // MARK: Attach sheet spoken (IDLE · was ComposerAttachmentsA11y)

    static let spokenAttachSheet = "adicionar anexo à mensagem"
    static let spokenAttachSheetHint =
        "foto, câmera, arquivo ou texto colado no próximo envio"
    static let spokenPhoto = "escolher foto da biblioteca"
    static let spokenPhotoHint =
        "abre a biblioteca de fotos; nada é anexado até escolher"
    static let spokenFile = "escolher arquivo"
    static let spokenFileHint = "PDF, texto, código ou dados do dispositivo"
    static let spokenPasteHint = "adiciona o texto copiado como contexto da mensagem"
    static let spokenPasteDisabledHint = "copie texto antes de colar como contexto"

    static func spokenPaste(hasText: Bool) -> String {
        hasText
            ? "colar contexto da área de transferência"
            : "colar indisponível, área de transferência vazia"
    }
}
