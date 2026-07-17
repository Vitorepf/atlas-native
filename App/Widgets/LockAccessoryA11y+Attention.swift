import AtlasCore
import Foundation

/// Attention gate — peel de LockAccessoryA11y.

enum LockAccessoryA11yAttention {
    static func hasAttention(_ snapshot: AtlasNativeSnapshot) -> Bool {
        snapshot.liveSessions?.contains { $0.timing == .paused } == true
    }
}
