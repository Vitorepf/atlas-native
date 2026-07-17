import AtlasCore
import SwiftUI

/// Mirror quiet spoken — peel de AtlasCodeMirrorCard+A11ySpokenState.
/// Mirrored → AtlasCodeMirrorCard+A11ySpokenState+Quiet+Mirrored.swift

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
