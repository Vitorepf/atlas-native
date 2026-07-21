import AtlasCore
import SwiftUI

/// Mirrored quiet spoken — peel de Mirror A11ySpokenState Quiet.

extension AtlasCodeMirrorCard {
    func spokenMirrorMirroredParts() -> [String]? {
        if case .mirrored = response.state {
            return ["tudo espelhado, verdade no Mac"]
        }
        return nil
    }
}
