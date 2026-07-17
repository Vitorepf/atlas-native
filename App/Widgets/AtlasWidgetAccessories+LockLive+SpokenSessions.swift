import AtlasCore
import Foundation

/// Live sessions spoken — peel de LockAccessoryA11y+Spoken.

extension LockAccessoryA11y {
    static func spokenLiveSessions(_ sessions: [AtlasNativeSnapshot.LiveSession]) -> [String] {
        let n = sessions.count
        guard let first = sessions.first else {
            return ["\(n) sessões vivas"]
        }
        return [n == 1
            ? "\(first.title), \(first.phaseTitle), em execução"
            : "\(n) sessões vivas, \(first.phaseTitle)"]
    }
}
