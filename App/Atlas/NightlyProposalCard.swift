import SwiftUI

struct NightlyProposalCard: View {
    let proposal: NightlyProposalController.ProposalPayload
    let onAccept: () -> Void
    /// Silêncio: some o card sem toast, sem confirmação, sem fila.
    let onDismiss: () -> Void
    let onMute: (Int) -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    static let muteDays = [1, 3, 7]

    var body: some View {
        cardChrome
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(A11yID.nightlyProposalCard)
            .accessibilityLabel(Self.spokenCardLabel(workspaceText: proposal.workspaceText))
            .accessibilityHint(Self.spokenCardHint())
    }
}
