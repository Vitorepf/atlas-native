import SwiftUI

// A11y shell — peel de NightlyProposalCard.

extension NightlyProposalCard {
    var cardA11y: some View {
        cardChrome
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(A11yID.nightlyProposalCard)
            .accessibilityLabel(Self.spokenCardLabel(workspaceText: proposal.workspaceText))
            .accessibilityHint(Self.spokenCardHint())
    }
}
