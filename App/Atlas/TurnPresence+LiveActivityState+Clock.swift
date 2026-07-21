import Foundation
import AtlasCore

// clock helper — peel de TurnPresence+LiveActivityState.

@MainActor
extension TurnPresence {
    static func clock(_ ms: Int) -> String {
        AtlasTime.formatActiveDuration(milliseconds: ms)
    }
}
