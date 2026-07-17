import SwiftUI
import AtlasCore

// Motor form — peel de ArenaRunSheet+FormSuites.

extension ArenaRunSheet {
    @ViewBuilder
    var engineFormSection: some View {
        section("MOTOR") {
            if engines.isEmpty {
                Text("nenhum motor publicado")
                    .font(.system(.subheadline))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityIdentifier(A11yID.arenaRunEnginesEmpty)
                    .accessibilityLabel(spokenEmptyEngines())
            } else {
                ForEach(engines, id: \.self) { engine in
                    toggleRow(title: engine, subtitle: nil, isOn: selectedEngine == engine) {
                        selectedEngine = engine
                    }
                    .accessibilityIdentifier("arena-run-engine-\(engine)")
                }
            }
        }
    }
}
