import SwiftUI
import AtlasCore

// MARK: - Arena suite sheet
// Engine card → +EngineCard · Toolbar → +Toolbar.swift
// Body → ArenaSuiteSheet+Body.swift
// Presentation → ArenaSuiteSheet+Presentation.swift

struct ArenaSuiteSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let suite: AtlasArenaSuite

    var body: some View {
        suitePresentation
    }
}
