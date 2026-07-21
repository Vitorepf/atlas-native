import Foundation
import AtlasCore

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
