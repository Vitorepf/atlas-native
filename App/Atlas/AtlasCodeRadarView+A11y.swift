import SwiftUI
import AtlasCore

/// Spoken labels do Radar — fase real e contagens do payload (WAVE-001 W3 fuse).
/// Ausência não inventa repositórios.

extension AtlasCodeRadarView {
    var contentPhaseID: String {
        contentPhaseBusyID ?? contentPhaseLoadedID
    }

    var contentPhaseBusyID: String? {
        switch model.phase {
        case .idle: return "idle"
        case .loading: return "loading"
        case .failed: return "failed"
        default: return nil
        }
    }

    var contentPhaseLoadedID: String {
        guard let workspace = model.workspace else { return "loaded-nil" }
        if workspace.repositoryCount == 0 { return "loaded-empty" }
        return "loaded-\(workspace.repositoryCount)"
    }

    var radarShellSpokenLabel: String {
        var parts = ["Código, workspace do operador"]
        if let busy = radarShellBusyParts() {
            parts.append(contentsOf: busy)
        } else {
            parts.append(contentsOf: radarShellLoadedParts())
        }
        return parts.joined(separator: ", ")
    }

    func radarShellBusyParts() -> [String]? {
        switch model.phase {
        case .idle, .loading:
            return [spokenLoading()]
        case .failed(let message):
            return [spokenFailed(message)]
        default:
            return nil
        }
    }

    func radarShellLoadedParts() -> [String] {
        if let workspace = model.workspace, workspace.repositoryCount > 0 {
            let n = workspace.repositoryCount
            return ["\(n) repositório\(n == 1 ? "" : "s")"]
        }
        return [spokenEmptyWorkspace()]
    }

    func spokenEmptyWorkspace() -> String { "nenhum repositório neste workspace" }

    static let shellHint = "pastas, recentes e sem retorno verificados do seu código"

    func spokenLoading() -> String { "lendo o workspace" }

    func spokenFailed(_ message: String) -> String {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "workspace indisponível" }
        return "workspace indisponível, \(trimmed)"
    }
}
