import SwiftUI
import AtlasCore

// Engine sheet scroll body — peel de ArenaEngineSheet.

extension ArenaEngineSheet {
    var engineScrollBody: some View {
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
}
