import SwiftUI
import AtlasCore

// MARK: - Arena engine sheet (peel de ArenaSuiteSheet)
// Summary → ArenaEngineSheet+Summary.swift
// Toolbar → ArenaEngineSheet+Toolbar.swift

struct ArenaEngineSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let engine: AtlasArenaCompositeEngine
    let capabilities: AtlasArenaCapabilities?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(engine.engine)
                        .font(.system(.title2, weight: .semibold))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                        .accessibilityLabel(ArenaEngineSheetA11y.spokenEngineTitle(engine.engine))
                    engineSummary
                    ArenaCapabilitiesSection(capabilities: capabilities, reduceMotion: reduceMotion)
                }
                .padding(AtlasTheme.Space.screen)
            }
            .background(AtlasTheme.bg.ignoresSafeArea())
            .navigationTitle("Motor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { engineToolbar }
        }
        .accessibilityIdentifier(A11yID.arenaEngineSheet)
        .accessibilityLabel(ArenaEngineSheetA11y.spokenSheet(engine, capabilities: capabilities))
        .accessibilityHint(ArenaEngineSheetA11y.sheetHint)
    }
}
