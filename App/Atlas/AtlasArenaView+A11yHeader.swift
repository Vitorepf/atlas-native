import SwiftUI
import AtlasCore

/// Header spoken — peel de AtlasArenaView+A11y.

extension AtlasArenaView {
    var headerSpokenLabel: String {
        var parts = ["Arena, medição dos motores"]
        if model.isDomainUnavailable, model.composite == nil {
            parts.append(ArenaModel.domainUnavailableCopy)
        }
        // Regressão e idade saíram do visual (veto do operador) — a voz
        // acompanha: regressão é dita na home e no disclosure das suítes.
        if let age = model.snapshotAgeText, model.composite != nil {
            parts.append("medido \(age)")
        }
        return parts.joined(separator: ", ")
    }
}
