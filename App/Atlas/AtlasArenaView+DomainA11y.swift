import SwiftUI
import AtlasCore

/// Domain-unavailable spoken — peel de AtlasArenaView+A11y.

extension AtlasArenaView {
    var domainUnavailableSpoken: String {
        "Arena, \(ArenaModel.domainUnavailableCopy)"
    }

    var domainUnavailableHint: String {
        "medição indisponível no servidor, sem scores publicados"
    }

    var runButtonSpoken: String { "Rodar medição" }

    var runButtonHint: String { "inicia nova rodada de medição governada" }

    func showsIndexSection(_ composite: AtlasArenaComposite) -> Bool {
        !composite.engines.isEmpty
    }
}
