import SwiftUI
import AtlasCore

// Domain/run spoken — peel de AtlasArenaView+DomainA11y.

extension AtlasArenaView {
    var domainUnavailableSpoken: String {
        "Arena, \(ArenaModel.domainUnavailableCopy)"
    }

    var domainUnavailableHint: String {
        "medição indisponível no servidor, sem scores publicados"
    }

    var runButtonSpoken: String { "Rodar medição" }

    var runButtonHint: String { "inicia nova rodada de medição governada" }
}
