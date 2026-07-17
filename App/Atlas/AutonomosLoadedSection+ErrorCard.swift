import SwiftUI
import AtlasCore

// Error card — peel de AutonomosLoadedSection+ReceiptCards.

struct AutonomosErrorCard: View {
    let message: String

    var body: some View {
        Text(message).font(.footnote).foregroundStyle(AtlasTheme.domOperacional)
            .padding(12).frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 12).fill(AtlasTheme.domOperacional.opacity(0.1)))
            .accessibilityLabel(AutonomosLoadedSectionA11y.spokenControlError(message))
            .accessibilityAddTraits(.isStaticText)
            .accessibilityIdentifier(A11yID.autonomosControlError)
    }
}
