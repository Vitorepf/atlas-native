import SwiftUI
import AtlasCore

/// Spoken screen label — peel de WorkspaceView (CICLO C residual honesty).

extension WorkspaceView {
    func spokenWorkspaceScreenLabel() -> String {
        if showsLoadingShell { return "\(title), carregando" }
        if showsNetworkFailure { return "\(title), offline" }
        let n = threads.count
        if n == 0 { return "\(title), nenhuma conversa neste filtro" }
        return "\(title), \(n) conversa\(n == 1 ? "" : "s"), filtro \(area.label)"
    }

    var workspaceScreenHint: String {
        freeOnly ? "conversas sem workspace" : "conversas deste workspace"
    }
}
