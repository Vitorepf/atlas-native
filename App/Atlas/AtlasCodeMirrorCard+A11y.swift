import AtlasCore
import SwiftUI

/// Phase id — peel de AtlasCodeMirrorCard (CICLO C residual honesty).
/// Spoken → AtlasCodeMirrorCard+A11ySpoken.swift
/// Counted → AtlasCodeMirrorCard+A11y+Counted.swift
/// QuietID → AtlasCodeMirrorCard+A11y+QuietID.swift

extension AtlasCodeMirrorCard {
    var mirrorStatePhaseID: String {
        mirrorStatePhaseCountedID
            ?? mirrorStatePhaseQuietID
            ?? "unknown"
    }
}
