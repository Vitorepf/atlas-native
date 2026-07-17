import AtlasCore
import SwiftUI

/// Quiet mirror phase ids — peel de AtlasCodeMirrorCard+A11y.

extension AtlasCodeMirrorCard {
    var mirrorStatePhaseQuietID: String? {
        switch response.state {
        case .mirrored: return "mirrored"
        case .noMirror: return "no-mirror"
        case .unknown: return "unknown"
        default: return nil
        }
    }
}
