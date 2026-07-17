import AtlasCore
import SwiftUI

/// Spoken labels da home — peel de RootHomeSections (CICLO C residual honesty).

extension RootHomeSections {
    static func codeTopBarLabel(hub: AtlasCodeHubModel?) -> String {
        guard let hub else { return "Atlas Código" }
        if let exception = hub.exception {
            return "Atlas Código, \(exception.count) exceções em \(exception.repo)"
        }
        return "Atlas Código, código quieto"
    }

    func conversasSpokenLabel(label: String, count: Int?) -> String {
        guard let count else { return label }
        return "\(label), \(count) conversa\(count == 1 ? "" : "s")"
    }

    func arenaSpokenLabel(regression: String?, domainUnavailable: Bool) -> String {
        if let regression { return "Arena, \(regression)" }
        if domainUnavailable { return "Arena, \(ArenaModel.domainUnavailableCopy)" }
        return "Arena, abre medição de regressão"
    }

    func workspaceSpokenLabel(name: String, count: Int?) -> String {
        guard let count else { return name }
        return "\(name), \(count) conversa\(count == 1 ? "" : "s")"
    }

    /// Chips só quando há workspaces reais — Livres/Todas ficam na linha CONVERSAS.
    var showsWorkspaceChips: Bool { !session.workspaces.isEmpty }

    /// WORKSPACES some quando não há pastas — "Todas" já vive nos chips.
    var showsWorkspacesSection: Bool { !session.workspaces.isEmpty }
}
