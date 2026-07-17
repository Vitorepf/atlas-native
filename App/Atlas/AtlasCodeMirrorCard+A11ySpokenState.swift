import AtlasCore
import SwiftUI

/// Mirror state spoken parts — peel de AtlasCodeMirrorCard+A11ySpoken.
/// Blocked → AtlasCodeMirrorCard+A11ySpokenState+Blocked.swift
/// Pending → AtlasCodeMirrorCard+A11ySpokenState+Pending.swift

extension AtlasCodeMirrorCard {
    func spokenMirrorStateParts() -> [String] {
        switch response.state {
        case .mirrored:
            return ["tudo espelhado, verdade no Mac"]
        case .pending(let commits):
            return spokenMirrorPendingParts(commits: commits)
        case .blocked(let rules):
            return spokenMirrorBlockedParts(rules: rules)
        case .noMirror:
            return ["sem espelho configurado"]
        case .unknown:
            return ["estado ainda não conhecido"]
        }
    }
}
