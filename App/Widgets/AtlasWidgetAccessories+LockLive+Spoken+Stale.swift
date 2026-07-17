import AtlasCore
import Foundation

// Stale suffix — peel de AtlasWidgetAccessories+LockLive+Spoken.

extension LockAccessoryA11y {
    static func spokenLabelStaleSuffix(stale: Bool, age: String) -> String? {
        stale ? "visto \(age)" : nil
    }
}
