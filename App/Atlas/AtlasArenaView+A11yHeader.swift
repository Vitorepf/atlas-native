import SwiftUI
import AtlasCore

/// Header spoken — peel de AtlasArenaView+A11y.

extension AtlasArenaView {
    var headerSpokenLabel: String {
        var parts = ["Arena, medição dos motores"]
        if let regression = model.regressionException {
            parts.append(regression)
        } else if model.isDomainUnavailable, model.composite == nil {
            parts.append(ArenaModel.domainUnavailableCopy)
        }
        if let age = model.snapshotAgeText, model.composite != nil {
            parts.append("snapshot \(age)")
        }
        return parts.joined(separator: ", ")
    }
}
