import Foundation
import AtlasCore

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
