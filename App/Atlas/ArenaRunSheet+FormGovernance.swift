import SwiftUI
import AtlasCore

// Governança + braços — peel de ArenaRunSheet+Form.
// Fields → ArenaRunSheet+FormGovernanceFields.swift

extension ArenaRunSheet {
    @ViewBuilder
    var formGovernanceSections: some View {
        section("Comparação") {
            ForEach(AtlasArenaRunArm.allCases) { arm in
                // Sublinha humana — "baseline"/"with_atlas" era slug de
                // máquina vazando na UI (canon: sem slug cru).
                toggleRow(title: arm.labelPT, subtitle: armSubtitle(arm), isOn: selectedArms.contains(arm)) {
                    if selectedArms.contains(arm), selectedArms.count > 1 { selectedArms.remove(arm) }
                    else { selectedArms.insert(arm) }
                }
                .accessibilityIdentifier("arena-run-arm-\(arm.rawValue)")
            }
        }

        governanceFields
    }

    func armSubtitle(_ arm: AtlasArenaRunArm) -> String {
        switch arm {
        case .baseline: "o motor puro, como referência"
        case .withAtlas: "os mesmos casos, com o Atlas"
        }
    }
}
