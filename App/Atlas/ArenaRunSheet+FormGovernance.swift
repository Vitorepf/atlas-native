import SwiftUI
import AtlasCore

// Governança + braços — peel de ArenaRunSheet+Form.
// Fields → ArenaRunSheet+FormGovernanceFields.swift

extension ArenaRunSheet {
    @ViewBuilder
    var formGovernanceSections: some View {
        section("BRAÇOS") {
            ForEach(AtlasArenaRunArm.allCases) { arm in
                toggleRow(title: arm.labelPT, subtitle: arm.rawValue, isOn: selectedArms.contains(arm)) {
                    if selectedArms.contains(arm), selectedArms.count > 1 { selectedArms.remove(arm) }
                    else { selectedArms.insert(arm) }
                }
                .accessibilityIdentifier("arena-run-arm-\(arm.rawValue)")
            }
        }

        governanceFields
    }
}
