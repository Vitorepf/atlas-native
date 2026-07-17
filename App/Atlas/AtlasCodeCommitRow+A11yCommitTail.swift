import Foundation
import AtlasCore

// Commit row tail — peel de AtlasCodeCommitRow+A11y.

extension AtlasCodeCommitRowA11y {
    static func spokenCommitTail(authoredAt: Int, isDimmed: Bool) -> [String] {
        var parts: [String] = []
        let when = AtlasCodeRelativeTime.short(from: authoredAt)
        if !when.isEmpty { parts.append("há \(when)") }
        if isDimmed { parts.append("fora da resposta") }
        return parts
    }
}
