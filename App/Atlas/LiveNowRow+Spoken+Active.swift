import SwiftUI
import AtlasCore

// Active spoken timing — peel de LiveNowRow+Spoken.

extension LiveNowRow {
    func spokenActiveLabel(prefix: String, now: Date) -> String? {
        switch session.timing {
        case .running:
            return spokenRunningLabel(prefix: prefix, now: now)
        case .paused:
            return spokenPausedLabel(prefix: prefix, now: now)
        default:
            return nil
        }
    }
}
