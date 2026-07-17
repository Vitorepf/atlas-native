import Foundation
import AtlasCore

/// Spoken labels das seções remanescentes — peel de ChangeReviewSections+Chrome (CICLO C).
/// Só campos publicados pelo servidor; score/decisão verbatim; toast = texto real.
/// Tests/decided → ChangeReviewSections+A11yDecided.swift
/// Controls → ChangeReviewSections+A11yControls.swift
/// RunHeader → ChangeReviewSections+A11yRunHeader.swift

enum ChangeReviewSectionsA11y {
    static func spokenCaption(_ text: String) -> String {
        text.lowercased()
    }
}
