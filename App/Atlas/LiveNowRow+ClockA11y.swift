import SwiftUI
import AtlasCore

// Clock a11y — peel de LiveNowRow+Clock.

extension LiveNowRow {
    func clockAccessibilityLabel(now: Date) -> String {
        guard let clock = spokenClock(now: now) else {
            return "tempo ativo indisponível"
        }
        return session.timing == .paused
            ? "tempo ativo congelado em \(clock)"
            : "tempo ativo \(clock)"
    }
}
