import AtlasCore
import SwiftUI

/// Mirror state spoken parts — peel de AtlasCodeMirrorCard+A11ySpoken.

extension AtlasCodeMirrorCard {
    func spokenMirrorStateParts() -> [String] {
        switch response.state {
        case .mirrored:
            return ["tudo espelhado, verdade no Mac"]
        case .pending(let commits):
            return ["\(commits) commit\(commits == 1 ? "" : "s") ainda só no Mac"]
        case .blocked(let rules):
            var parts = ["bloqueado, segredo detectado"]
            if !rules.isEmpty {
                parts.append("regras \(rules.joined(separator: ", "))")
            }
            return parts
        case .noMirror:
            return ["sem espelho configurado"]
        case .unknown:
            return ["estado ainda não conhecido"]
        }
    }
}
