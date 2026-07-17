import Foundation
import AtlasCore

/// Spoken labels do thumb de anexo — peel de DraftThumb (CICLO C).
/// Tamanho só quando bytes publicados; tipo imagem/arquivo honesto.
/// Hints → DraftThumb+A11yHints.swift
/// Thumb → DraftThumb+A11yThumb.swift

enum DraftThumbA11y {
    static func spokenRemove(_ draft: LocalDraft) -> String {
        DraftThumbA11yHints.spokenRemove(draft)
    }

    static let removeHint = DraftThumbA11yHints.removeHint
    static let failedHint = DraftThumbA11yHints.failedHint

    static func spokenFailedValue(_ message: String) -> String {
        DraftThumbA11yHints.spokenFailedValue(message)
    }
}
