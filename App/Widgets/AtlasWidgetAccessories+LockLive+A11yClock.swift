import AtlasCore
import Foundation

/// Frozen clock helper — peel de AtlasWidgetAccessories+LockLive+A11y.

extension LockAccessoryA11y {
    static func frozenClock(_ session: AtlasNativeSnapshot.LiveSession) -> String? {
        guard session.timing == .paused, let ms = session.elapsedActiveMs else { return nil }
        return AtlasTime.formatActiveDuration(milliseconds: ms)
    }
}
