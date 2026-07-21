import Foundation
import AtlasCore

/// Section spoken — peel de ChangeReviewCouncilRow+A11y.

enum ChangeReviewCouncilA11y {
    static func spokenSection(memberCount: Int, diverged: Bool) -> String {
        var parts = ["conselho, \(memberCount) \(memberCount == 1 ? "membro" : "membros")"]
        if diverged { parts.append("divergência entre pareceres") }
        return parts.joined(separator: ", ")
    }
}
