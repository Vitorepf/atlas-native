import AtlasCore
import Foundation

// Live paused spoken — peel de LiveSessionWidgetA11y+Spoken.

extension LiveSessionWidgetA11y {
    static func spokenLiveParts(_ live: AtlasNativeSnapshot.LiveSession) -> [String] {
        var parts = ["\(live.title), \(live.phaseTitle)"]
        if live.timing == .paused {
            parts.append("pausado")
            if let clock = LockAccessoryA11y.frozenClock(live) {
                parts.append("tempo congelado \(clock)")
            }
        } else {
            parts.append("em execução")
        }
        return parts
    }
}
