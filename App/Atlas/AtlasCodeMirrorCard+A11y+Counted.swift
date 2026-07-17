import AtlasCore
import SwiftUI

/// Mirror phase id pending/blocked — peel de AtlasCodeMirrorCard+A11y.

extension AtlasCodeMirrorCard {
    var mirrorStatePhaseCountedID: String? {
        switch response.state {
        case .pending(let commits): return "pending-\(commits)"
        case .blocked(let rules): return "blocked-\(rules.joined(separator: "-"))"
        default: return nil
        }
    }
}
