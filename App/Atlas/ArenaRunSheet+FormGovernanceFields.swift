import SwiftUI
import AtlasCore

// Governance fields — peel de ArenaRunSheet+FormGovernance.

extension ArenaRunSheet {
    @ViewBuilder
    var governanceFields: some View {
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
