import AtlasCore
import SwiftUI

/// Mirror state spoken parts — peel de AtlasCodeMirrorCard+A11ySpoken.
/// Blocked → AtlasCodeMirrorCard+A11ySpokenState+Blocked.swift
/// Pending → AtlasCodeMirrorCard+A11ySpokenState+Pending.swift
/// Quiet → AtlasCodeMirrorCard+A11ySpokenState+Quiet.swift

extension AtlasCodeMirrorCard {
    func spokenMirrorStateParts() -> [String] {
        if let quiet = spokenMirrorQuietParts() { return quiet }
        switch response.state {
        case .pending(let commits):
            return spokenMirrorPendingParts(commits: commits)
        case .blocked(let rules):
            return spokenMirrorBlockedParts(rules: rules)
        default:
            return ["estado ainda não conhecido"]
        }
    }
}
