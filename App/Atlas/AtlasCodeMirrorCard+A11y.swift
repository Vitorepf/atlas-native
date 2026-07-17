import AtlasCore
import SwiftUI

/// Phase id — peel de AtlasCodeMirrorCard (CICLO C residual honesty).
/// Spoken → AtlasCodeMirrorCard+A11ySpoken.swift

extension AtlasCodeMirrorCard {
    var mirrorStatePhaseID: String {
        switch response.state {
        case .mirrored: return "mirrored"
        case .pending(let commits): return "pending-\(commits)"
        case .blocked(let rules): return "blocked-\(rules.joined(separator: "-"))"
        case .noMirror: return "no-mirror"
        case .unknown: return "unknown"
        }
    }
}
