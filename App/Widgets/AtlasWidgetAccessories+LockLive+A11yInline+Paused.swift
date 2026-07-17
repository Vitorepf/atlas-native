import AtlasCore
import Foundation

/// Paused rectangular subtitle — peel de LockLive A11yInline.

extension LockAccessoryA11y {
    static func rectangularPausedSubtitle(_ first: AtlasNativeSnapshot.LiveSession) -> String {
        if let clock = frozenClock(first) { return "‖ \(clock)" }
        return "‖ pausado"
    }
}
