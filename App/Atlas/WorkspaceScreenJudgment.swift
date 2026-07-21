import Foundation
import AtlasCore

// MARK: - Types

/// Exclusive Workspace screen face (WAVE-073).
enum WorkspaceScreenFace: Equatable {
    case loading
    case offline
    case empty
    case list(Int)

    var productWord: String {
        switch self {
        case .loading: return "loading"
        case .offline: return "offline"
        case .empty: return "empty"
        case .list: return "list"
        }
    }

    var spokenFace: String {
        switch self {
        case .loading: return "carregando"
        case .offline: return "offline"
        case .empty: return "nenhuma conversa neste filtro"
        case .list(let n):
            return n == 1 ? "1 conversa" : "\(n) conversas"
        }
    }
}

// MARK: - Judgment

/// Pure workspace-screen grammar — face · spoken · pack.
enum WorkspaceScreenJudgment {

    static func face(
        showsLoadingShell: Bool,
        showsNetworkFailure: Bool,
        threadCount: Int
    ) -> WorkspaceScreenFace {
        if showsLoadingShell { return .loading }
        if showsNetworkFailure { return .offline }
        if threadCount <= 0 { return .empty }
        return .list(threadCount)
    }

    static func spokenScreen(
        title: String,
        face: WorkspaceScreenFace,
        areaLabel: String
    ) -> String {
        switch face {
        case .loading:
            return "\(title), carregando"
        case .offline:
            return "\(title), offline"
        case .empty:
            return "\(title), nenhuma conversa neste filtro"
        case .list(let n):
            return "\(title), \(n) conversa\(n == 1 ? "" : "s"), filtro \(areaLabel)"
        }
    }

    static func screenHint(freeOnly: Bool) -> String {
        freeOnly ? "conversas sem workspace" : "conversas deste workspace"
    }

    static func packFacts(
        title: String,
        showsLoadingShell: Bool,
        showsNetworkFailure: Bool,
        threadCount: Int,
        areaLabel: String,
        freeOnly: Bool
    ) -> (facts: [String], absences: [String]) {
        var facts: [String] = []
        var absences: [String] = []
        let face = face(
            showsLoadingShell: showsLoadingShell,
            showsNetworkFailure: showsNetworkFailure,
            threadCount: threadCount
        )
        facts.append("workspace_face: \(face.productWord)")
        facts.append("workspace_title: \(title)")
        facts.append("workspace_area: \(areaLabel)")
        if freeOnly { facts.append("workspace_free_only: true") }
        switch face {
        case .loading:
            absences.append("workspace ainda carregando")
        case .offline:
            absences.append("workspace offline")
        case .empty:
            absences.append("nenhuma conversa neste filtro")
            facts.append("workspace_threads: 0")
        case .list(let n):
            facts.append("workspace_threads: \(n)")
        }
        return (facts, absences)
    }
}
