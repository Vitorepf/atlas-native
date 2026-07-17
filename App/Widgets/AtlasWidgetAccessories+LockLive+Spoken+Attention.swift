import AtlasCore
import Foundation

// Attention/paused branch — peel de AtlasWidgetAccessories+LockLive+Spoken.

extension LockAccessoryA11y {
    static func spokenAttentionLine(_ snapshot: AtlasNativeSnapshot) -> String? {
        guard hasAttention(snapshot),
              let paused = snapshot.liveSessions?.first(where: { $0.timing == .paused }) else {
            return nil
        }
        var parts = ["\(paused.title), pausado"]
        if let clock = frozenClock(paused) { parts.append("tempo congelado \(clock)") }
        return parts.joined(separator: ", ")
    }
}
