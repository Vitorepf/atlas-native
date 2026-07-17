import AtlasCore
import SwiftUI

/// Mirror quiet spoken — peel de AtlasCodeMirrorCard+A11ySpokenState.

extension AtlasCodeMirrorCard {
    func spokenMirrorQuietParts() -> [String]? {
        switch response.state {
        case .mirrored:
            return ["tudo espelhado, verdade no Mac"]
        case .noMirror:
            return ["sem espelho configurado"]
        case .unknown:
            return ["estado ainda não conhecido"]
        default:
            return nil
        }
    }
}
