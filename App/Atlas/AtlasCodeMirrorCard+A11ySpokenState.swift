import AtlasCore
import SwiftUI

// Cycle 039 fuse → AtlasCodeMirrorCard+A11ySpokenState.swift

extension AtlasCodeMirrorCard {
    func spokenMirrorBlockedParts(rules: [String]) -> [String] {
        var parts = ["bloqueado, segredo detectado"]
        if !rules.isEmpty {
            parts.append("regras \(rules.joined(separator: ", "))")
        }
        return parts
    }
}

extension AtlasCodeMirrorCard {
    func spokenMirrorPendingParts(commits: Int) -> [String] {
        ["\(commits) commit\(commits == 1 ? "" : "s") ainda só no Mac"]
    }
}

extension AtlasCodeMirrorCard {
    func spokenMirrorMirroredParts() -> [String]? {
        if case .mirrored = response.state {
            return ["tudo espelhado, verdade no Mac"]
        }
        return nil
    }
}

extension AtlasCodeMirrorCard {
    func spokenMirrorQuietParts() -> [String]? {
        if let mirrored = spokenMirrorMirroredParts() { return mirrored }
        switch response.state {
        case .noMirror:
            return ["sem espelho configurado"]
        case .unknown:
            return ["estado ainda não conhecido"]
        default:
            return nil
        }
    }
}

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
