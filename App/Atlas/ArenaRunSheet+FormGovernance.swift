import SwiftUI
import AtlasCore

// Governança + braços — peel de ArenaRunSheet+Form.

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

        section("GOVERNANÇA") {
            TextField("ator", text: $actor)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .accessibilityIdentifier(A11yID.arenaRunActor)
                .accessibilityHint(spokenActorHint())
            TextField("motivo auditável", text: $reason, axis: .vertical)
                .lineLimit(2...4)
                .accessibilityIdentifier(A11yID.arenaRunReason)
                .accessibilityHint(spokenReasonHint())
        }
        .textFieldStyle(.roundedBorder)
    }
}
