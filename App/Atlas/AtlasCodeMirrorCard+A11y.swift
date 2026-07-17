import AtlasCore
import SwiftUI

/// Phase id — peel de AtlasCodeMirrorCard (CICLO C residual honesty).
/// Spoken → AtlasCodeMirrorCard+A11ySpoken.swift
/// Counted → AtlasCodeMirrorCard+A11y+Counted.swift

extension AtlasCodeMirrorCard {
    var mirrorStatePhaseID: String {
        if let counted = mirrorStatePhaseCountedID { return counted }
        switch response.state {
        case .mirrored: return "mirrored"
        case .noMirror: return "no-mirror"
        case .unknown: return "unknown"
        default: return "unknown"
        }
    }
}
