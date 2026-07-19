import SwiftUI
import AtlasCore

// Motor form — peel de ArenaRunSheet+FormSuites.
// Empty → ArenaRunSheet+FormEngine+Empty.swift

extension ArenaRunSheet {
    @ViewBuilder
    var engineFormSection: some View {
        section("Motores") {
            if engines.isEmpty {
                engineFormEmpty
            } else {
                ForEach(engines, id: \.self) { engine in
                    toggleRow(
                        title: ArenaDisplay.engine(engine),
                        subtitle: nil,
                        isOn: selectedEngines.contains(engine)
                    ) {
                        if selectedEngines.contains(engine) {
                            selectedEngines.remove(engine)
                        } else {
                            selectedEngines.insert(engine)
                        }
                    }
                    .accessibilityIdentifier("arena-run-engine-\(engine)")
                }
                if engines.count > 1 {
                    Text("Escolha 2 ou mais para comparar motor contra motor.")
                        .font(.system(.caption))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .accessibilityHidden(true)
                }
            }
        }
    }
}
