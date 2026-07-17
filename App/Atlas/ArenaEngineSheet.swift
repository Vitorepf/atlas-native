import SwiftUI
import AtlasCore

// MARK: - Arena engine sheet (peel de ArenaSuiteSheet)
// Summary → ArenaEngineSheet+Summary.swift
// Toolbar → ArenaEngineSheet+Toolbar.swift
// Scroll → ArenaEngineSheet+ScrollBody.swift

struct ArenaEngineSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let engine: AtlasArenaCompositeEngine
    let capabilities: AtlasArenaCapabilities?

    var body: some View {
        NavigationStack {
            engineScrollBody
        }
        .accessibilityIdentifier(A11yID.arenaEngineSheet)
        .accessibilityLabel(ArenaEngineSheetA11y.spokenSheet(engine, capabilities: capabilities))
        .accessibilityHint(ArenaEngineSheetA11y.sheetHint)
    }
}
