import SwiftUI
import AtlasCore

// Motor form — peel de ArenaRunSheet+FormSuites.
// Empty → ArenaRunSheet+FormEngine+Empty.swift

extension ArenaRunSheet {
    @ViewBuilder
    var engineFormSection: some View {
        section("MOTOR") {
            if engines.isEmpty {
                engineFormEmpty
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
