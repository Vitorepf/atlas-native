import Foundation
import AtlasCore
import SwiftUI

// GOD-RESTRUCTURE: ComposerJudgments fused

// MARK: - ComposerToolbarJudgment

// MARK: - Judgment

/// Pure composer toolbar chrome grammar (WAVE-091).
/// Attach · options · mode · workspace spoken — not send (046) · not effort (076) · not draft (086).
enum ComposerToolbarJudgment {

    static let attachLabel = "adicionar anexo"
    static let attachHint = "abre foto, arquivo ou colar"
    static let optionsLabel = "opções da conversa"
    static let defaultWorkspaceName = "Atlas"

    // MARK: Spoken

    static func spokenAttach() -> String { attachLabel }

    static func spokenAttachHint() -> String { attachHint }

    static func spokenOptions() -> String { optionsLabel }

    /// WAVE-076 already owns effort options hint composition at call sites.
    static func spokenOptionsHint(effortOptionsHint: String) -> String {
        effortOptionsHint
    }

    static func spokenMode(_ mode: String) -> String {
        let trimmed = mode.trimmingCharacters(in: .whitespacesAndNewlines)
        let name = trimmed.isEmpty ? "geral" : trimmed
        return "modo, \(name)"
    }

    static func spokenWorkspace(_ name: String?) -> String {
        let resolved = resolvedWorkspaceName(name)
        return "workspace, \(resolved)"
    }

    static func resolvedWorkspaceName(_ name: String?) -> String {
        let trimmed = name?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmed.isEmpty ? defaultWorkspaceName : trimmed
    }

    static func workspaceMenuTitle(_ name: String?) -> String {
        "Workspace: \(resolvedWorkspaceName(name))"
    }

    static func modeMenuTitle(_ mode: String) -> String {
        let trimmed = mode.trimmingCharacters(in: .whitespacesAndNewlines)
        let name = trimmed.isEmpty ? "geral" : trimmed
        return "Modo: \(name.capitalized)"
    }

    // MARK: Composer card (host shell)

    static let cardHint =
        "escreve, anexa e envia; fila e execução viva aparecem quando publicadas"

    static func spokenCard(
        expanded: Bool,
        draftCount: Int,
        queueCount: Int,
        isSending: Bool
    ) -> String {
        var parts = ["compositor"]
        if expanded { parts.append("expandido") }
        if draftCount > 0 {
            parts.append("\(draftCount) anexo\(draftCount == 1 ? "" : "s")")
        }
        if queueCount > 0 {
            parts.append("\(queueCount) na fila")
        }
        if isSending { parts.append("enviando") }
        return parts.joined(separator: ", ")
    }

    // MARK: Pack

    static func packFacts(
        mode: String,
        workspaceName: String?,
        effort: AtlasComputeEffort
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        facts.append("toolbar_mode: \(mode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "geral" : mode)")
        facts.append("toolbar_workspace: \(resolvedWorkspaceName(workspaceName))")
        facts.append("toolbar_effort: \(effort.shortLabel)")
        if workspaceName == nil || workspaceName?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true {
            absences.append("workspace slug não publicado — label Atlas local")
        }
        return (facts, absences)
    }
}
// MARK: - ComposerEffortJudgment

// MARK: - Types

/// Exclusive composer effort face (WAVE-076).
enum ComposerEffortFace: Equatable {
    case auto
    case fast
    case balanced
    case deep
    case max

    var productWord: String {
        switch self {
        case .auto: return "auto"
        case .fast: return "fast"
        case .balanced: return "balanced"
        case .deep: return "deep"
        case .max: return "max"
        }
    }

    /// Toolbar-rich spoken (includes Atlas Decide honesty for auto).
    var spokenToolbar: String {
        switch self {
        case .auto: return "esforço automático, Atlas Decide escolhe"
        case .fast: return "esforço rápido"
        case .balanced: return "esforço normal"
        case .deep: return "esforço profundo"
        case .max: return "esforço máximo"
        }
    }

    /// Sheet list spoken (short product line).
    var spokenSheet: String {
        switch self {
        case .auto: return "esforço automático"
        case .fast: return "esforço rápido"
        case .balanced: return "esforço normal"
        case .deep: return "esforço profundo"
        case .max: return "esforço máximo"
        }
    }

    var subtitle: String {
        switch self {
        case .auto: return "Atlas Decide escolhe; nada vai no payload"
        case .fast: return "força rápido no próximo envio"
        case .balanced: return "força normal no próximo envio"
        case .deep: return "força profundo no próximo envio"
        case .max: return "força máximo no próximo envio"
        }
    }
}

// MARK: - Judgment

/// Pure composer effort grammar — face · spoken · pack.
enum ComposerEffortJudgment {

    static let effortHint = "abre opções de esforço computacional para o próximo envio"
    static let effortSheetHint = "escolhe o esforço computacional do próximo envio"
    static let effortSheetLabel = "esforço computacional"
    static let processingLabel = "Atlas processando"

    static func face(_ effort: AtlasComputeEffort) -> ComposerEffortFace {
        switch effort {
        case .auto: return .auto
        case .fast: return .fast
        case .balanced: return .balanced
        case .deep: return .deep
        case .max: return .max
        }
    }

    static func spokenToolbar(_ effort: AtlasComputeEffort) -> String {
        face(effort).spokenToolbar
    }

    static func spokenSheet(_ effort: AtlasComputeEffort) -> String {
        face(effort).spokenSheet
    }

    static func spokenSheetLabel(_ effort: AtlasComputeEffort, selected: Bool) -> String {
        let state = selected ? "selecionado" : "disponível"
        return "\(spokenSheet(effort)), \(state)"
    }

    static func subtitle(_ effort: AtlasComputeEffort) -> String {
        face(effort).subtitle
    }

    static func spokenInputLabel(bubblesEmpty: Bool) -> String {
        bubblesEmpty ? "mensagem para o Atlas" : "continuar conversa com o Atlas"
    }

    static func spokenInputHint(canSubmit: Bool, isExecuting: Bool) -> String {
        if canSubmit {
            return isExecuting
                ? "texto para a fila do próximo turno"
                : "texto do próximo envio"
        }
        return "escreva aqui para habilitar o envio"
    }

    static func spokenOptionsHint(sendHint: String) -> String {
        "modo, esforço e workspace; \(sendHint.lowercased())"
    }

    static func packFacts(effort: AtlasComputeEffort) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(effort)
        facts.append("composer_effort_face: \(face.productWord)")
        facts.append("composer_effort_short: \(effort.shortLabel)")
        if effort == .auto {
            absences.append("esforço auto — Atlas Decide escolhe; sem nível no payload")
        } else if let payload = effort.payloadValue {
            facts.append("composer_effort_payload: \(payload)")
        }
        return (facts, absences)
    }
}
// MARK: - ComposerQueueJudgment

// MARK: - Types

/// Exclusive follow-up queue face (WAVE-051). FIFO order is sacred.
enum ComposerQueueFace: Equatable {
    case empty
    case single
    case multi(Int)

    var productWord: String {
        switch self {
        case .empty: return "empty"
        case .single: return "single"
        case .multi: return "multi"
        }
    }

    var spokenFace: String {
        switch self {
        case .empty:
            return "fila vazia"
        case .single:
            return "1 mensagem na fila"
        case .multi(let n):
            return "\(n) mensagens na fila"
        }
    }
}

// MARK: - Judgment

/// Pure composer queue grammar — face · head · labels · pack.
/// Does **not** re-order FIFO (model owns promote/remove).
enum ComposerQueueJudgment {

    static func face(from messages: [QueuedMessage]) -> ComposerQueueFace {
        switch messages.count {
        case 0: return .empty
        case 1: return .single
        default: return .multi(messages.count)
        }
    }

    /// FIFO head — first message sends when the turn ends.
    static func head(from messages: [QueuedMessage]) -> QueuedMessage? {
        messages.first
    }

    /// Operator-safe snippet; empty text → honest absence label.
    static func snippet(_ text: String, maxChars: Int = 28) -> String {
        let trimmed = text
            .replacingOccurrences(of: "\n", with: " ")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return "(sem texto)" }
        if trimmed.count <= maxChars { return trimmed }
        return String(trimmed.prefix(maxChars - 1)) + "…"
    }

    static func chipLabel(from messages: [QueuedMessage]) -> String {
        let face = face(from: messages)
        guard let head = head(from: messages) else { return "Fila" }
        let snip = snippet(head.text)
        switch face {
        case .empty:
            return "Fila"
        case .single:
            return "Fila · \(snip)"
        case .multi(let n):
            return "Fila · \(n) · \(snip)"
        }
    }

    static func sheetTitle(from messages: [QueuedMessage]) -> String {
        switch face(from: messages) {
        case .empty: return "Fila"
        case .single: return "Fila · 1"
        case .multi(let n): return "Fila · \(n)"
        }
    }

    static func spokenChip(from messages: [QueuedMessage]) -> String {
        let face = face(from: messages)
        guard let head = head(from: messages) else { return face.spokenFace }
        let snip = snippet(head.text, maxChars: 48)
        switch face {
        case .empty:
            return face.spokenFace
        case .single:
            return "1 mensagem na fila durante a execução, próxima \(snip)"
        case .multi(let n):
            return "\(n) mensagens na fila durante a execução, próxima \(snip)"
        }
    }

    static func spokenSheet(from messages: [QueuedMessage]) -> String {
        let face = face(from: messages)
        guard let head = head(from: messages) else { return face.spokenFace }
        let snip = snippet(head.text, maxChars: 64)
        switch face {
        case .empty:
            return "fila vazia"
        case .single:
            return "fila, 1 mensagem, cabeça \(snip)"
        case .multi(let n):
            return "fila, \(n) mensagens, cabeça \(snip), a primeira envia quando o turno terminar"
        }
    }

    static func packFacts(from messages: [QueuedMessage]) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(from: messages)
        facts.append("queue_face: \(face.productWord)")
        facts.append("queue_count: \(messages.count)")
        guard let head = head(from: messages) else {
            absences.append("fila de follow-up vazia neste recorte")
            return (facts, absences)
        }
        facts.append("queue_head: \(snippet(head.text, maxChars: 80))")
        facts.append("queue_head_age_s: \(max(0, Int(Date().timeIntervalSince(head.createdAt))))")
        if messages.count > 1, let tail = messages.last {
            facts.append("queue_tail: \(snippet(tail.text, maxChars: 40))")
        }
        return (facts, absences)
    }
}
// MARK: - ComposerSendJudgment

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

    // MARK: Pack (WAVE-178)

    static func packFacts(
        draftText: String,
        drafts: [LocalDraft],
        isSending: Bool,
        liveBubblePresent: Bool
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(
            draftText: draftText,
            drafts: drafts,
            isSending: isSending,
            liveBubblePresent: liveBubblePresent
        )
        facts.append("send_face: \(face.productWord)")
        facts.append("send_allows: \(face.allowsSend ? "yes" : "no")")
        switch face {
        case .empty:
            absences.append("composer sem payload — sem mensagem nem anexo pronto")
        case .ready:
            break
        case .blockedFailed:
            absences.append("anexo falhou — remova ou reconecte antes de enviar")
        case .blockedUploading:
            absences.append("anexo ainda subindo — CTA bloqueado até pronto")
        case .queueOnly:
            facts.append("send_mode: queue_followup")
        case .executing:
            absences.append("Atlas processando — escreva para enfileirar follow-up")
        }
        absences.append("NL de chat não dispara send — só CTA gold do composer")
        return (facts, absences)
    }
}
// MARK: - ComposerDraftJudgment

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

}

// MARK: - Attach spoken

extension ComposerDraftJudgment {
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

    // MARK: Camera attach spoken (IDLE · was CameraPickerA11y)

    static let spokenCameraSurface = "câmera para anexar foto"
    static let spokenCameraHint =
        "confirme a captura para anexar; cancelar não adiciona nada"
    static let captureFailedToast = "não consegui capturar a foto"
    static let spokenChooseCamera = "capturar foto na câmera"
    static let spokenChooseCameraHint =
        "abre a câmera; nada é anexado até confirmar a captura"

    // MARK: Attachment row spoken (IDLE)

    static func spokenAttachmentRow(title: String, subtitle: String) -> String {
        "\(title), \(subtitle)"
    }


}
// MARK: - ComposerSheetJudgment

// MARK: - Types

/// Exclusive composer local-mode face (WAVE-081).
/// Honesty: rótulo local — ainda não altera roteamento nem payload.
enum ComposerModeFace: Equatable {
    case geral
    case operacional
    case autonomos
    case programacao
    case unknown(String)

    var productWord: String {
        switch self {
        case .geral: return "geral"
        case .operacional: return "operacional"
        case .autonomos: return "autonomos"
        case .programacao: return "programacao"
        case .unknown(let key): return key.isEmpty ? "unknown" : key
        }
    }

    var title: String {
        switch self {
        case .geral: return "Geral"
        case .operacional: return "Operacional"
        case .autonomos: return "Autônomos"
        case .programacao: return "Programação"
        case .unknown(let key): return key
        }
    }

    var key: String {
        switch self {
        case .geral: return "geral"
        case .operacional: return "operacional"
        case .autonomos: return "autônomos"
        case .programacao: return "programação"
        case .unknown(let key): return key
        }
    }
}

/// Exclusive composer workspace-sheet face (WAVE-081).
enum ComposerWorkspaceSheetFace: Equatable {
    case empty
    case list(Int)

    var productWord: String {
        switch self {
        case .empty: return "empty"
        case .list: return "list"
        }
    }

    var spokenFace: String {
        switch self {
        case .empty:
            return "nenhum workspace nas conversas carregadas"
        case .list(let n):
            return n == 1 ? "1 workspace" : "\(n) workspaces"
        }
    }
}

// MARK: - Judgment

/// Pure composer options-sheet grammar — mode · workspace sheet · pack.
enum ComposerSheetJudgment {

    static let modeFootnote =
        "rótulo local; ainda não altera roteamento nem payload"
    static let modeSheetHint = "escolhe um rótulo local; não altera o turno ainda"
    static let workspaceSheetHint =
        "escolhe a pasta do próximo envio entre as conversas carregadas"
    static let workspaceEmpty =
        "nenhum workspace nas conversas carregadas; abra uma conversa com pasta ou volte à home"
    static let workspaceSheetSpokenLabel = "workspace da conversa"
    static let modeSheetSpokenLabel = "modo da conversa"

    /// Canonical mode table (single source for ModeSheet).
    static let modes: [(key: String, title: String)] = [
        ("geral", "Geral"),
        ("operacional", "Operacional"),
        ("autônomos", "Autônomos"),
        ("programação", "Programação"),
    ]

    static func modeFace(key: String) -> ComposerModeFace {
        switch key {
        case "geral": return .geral
        case "operacional": return .operacional
        case "autônomos": return .autonomos
        case "programação": return .programacao
        default: return .unknown(key)
        }
    }

    static func modeLabel(key: String, title: String, selected: Bool) -> String {
        let state = selected ? "selecionado" : "disponível"
        return "modo \(title), \(state), \(modeFootnote)"
    }

    static func modeLabel(key: String, selected: Bool) -> String {
        let face = modeFace(key: key)
        let title = modes.first(where: { $0.key == key })?.title ?? face.title
        return modeLabel(key: key, title: title, selected: selected)
    }

    static func workspaceSheetFace(count: Int) -> ComposerWorkspaceSheetFace {
        count <= 0 ? .empty : .list(count)
    }

    static func workspaceLabel(name: String, count: Int, selected: Bool) -> String {
        let noun = count == 1 ? "conversa" : "conversas"
        let state = selected ? "workspace atual" : "disponível"
        return "\(name), \(count) \(noun) carregadas, \(state)"
    }

    static func workspaceCountLine(_ count: Int) -> String {
        count == 1 ? "1 conversa carregada" : "\(count) conversas carregadas"
    }

    /// Shared sheet row shell spoken (label · sub · selection).
    static func spokenShellRow(label: String, sub: String?, selected: Bool) -> String {
        var parts = [label]
        if let sub, !sub.isEmpty { parts.append(sub) }
        parts.append(selected ? "selecionado" : "disponível")
        return parts.joined(separator: ", ")
    }

    static let newSinceLastVisitLabel = "novo desde a última visita"

    static func packFacts(
        modeKey: String?,
        workspaceCount: Int,
        currentWorkspace: String?
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        if let modeKey {
            let face = modeFace(key: modeKey)
            facts.append("composer_mode_face: \(face.productWord)")
            facts.append("composer_mode_local_only: true")
        } else {
            absences.append("modo local não selecionado neste recorte")
        }
        let wsFace = workspaceSheetFace(count: workspaceCount)
        facts.append("composer_workspace_sheet_face: \(wsFace.productWord)")
        facts.append("composer_workspace_count: \(workspaceCount)")
        if let currentWorkspace, !currentWorkspace.isEmpty {
            facts.append("composer_workspace_current: \(currentWorkspace)")
        }
        if case .empty = wsFace {
            absences.append("nenhum workspace nas conversas carregadas")
        }
        return (facts, absences)
    }
}
