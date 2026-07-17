import AtlasCore
import SwiftUI

/// Spoken labels da home — peel de RootHomeSections (CICLO C residual honesty).
/// Visibility → RootHomeSections+A11yVisibility.swift

extension RootHomeSections {
    static func codeTopBarLabel(hub: AtlasCodeHubModel?) -> String {
        guard let hub else { return "Atlas Código" }
        if let exception = hub.exception {
            return "Atlas Código, \(exception.count) exceções em \(exception.repo)"
        }
        return "Atlas Código, código quieto"
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
}
