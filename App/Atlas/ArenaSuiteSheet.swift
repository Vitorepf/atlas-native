import SwiftUI
import AtlasCore

// MARK: - Arena suite sheet
// Engine card → +EngineCard · Toolbar → +Toolbar.swift
// Body → ArenaSuiteSheet+Body.swift

struct ArenaSuiteSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let suite: AtlasArenaSuite

    var body: some View {
        NavigationStack {
            suiteScrollBody
        }
        .accessibilityIdentifier(A11yID.arenaSuiteSheet)
        .accessibilityLabel(ArenaSuiteSheetA11y.spokenSheet(suite))
        .accessibilityHint(ArenaSuiteSheetA11y.sheetHint)
    }
}
