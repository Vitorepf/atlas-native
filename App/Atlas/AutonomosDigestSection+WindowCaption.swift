import SwiftUI
import AtlasCore

// Digest window caption — peel de AutonomosDigestSection+Predicates.

extension AutonomosNextDigestSection {
    /// Janela governada publicada pelo servidor — sem inventar horário de agenda.
    func digestWindowCaption(_ digest: AtlasAutonomosDigestResponse) -> String? {
        let window = digest.last.window
        guard window.hours > 0 else { return nil }
        var parts = ["janela \(window.hours)h"]
        if let ended = AtlasTime.date(window.endedAt) {
            parts.append("fechou há \(atlasRelativeAgePT(since: ended))")
        }
        return parts.joined(separator: " · ")
    }
}
