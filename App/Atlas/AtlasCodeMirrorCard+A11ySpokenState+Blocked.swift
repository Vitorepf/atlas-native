import AtlasCore
import SwiftUI

/// Mirror blocked spoken — peel de AtlasCodeMirrorCard+A11ySpokenState.

extension AtlasCodeMirrorCard {
    func spokenMirrorBlockedParts(rules: [String]) -> [String] {
        var parts = ["bloqueado, segredo detectado"]
        if !rules.isEmpty {
            parts.append("regras \(rules.joined(separator: ", "))")
        }
        return parts
    }
}
