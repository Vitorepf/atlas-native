import SwiftUI
import AtlasCore

// Control receipt + error — peel de AutonomosLoadedSection+Lines.

struct AutonomosControlReceiptLine: View {
    let receipt: AtlasAutonomosRunControlResponse

    var body: some View {
        Text(receipt.note)
            .font(.footnote).foregroundStyle(AtlasTheme.textSecondary)
            .padding(12).frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 12).fill(AtlasTheme.domAutonomos.opacity(0.1)))
            .accessibilityLabel(AutonomosLoadedSectionA11y.spokenControlReceipt(receipt))
            .accessibilityAddTraits(.isStaticText)
            .accessibilityIdentifier(A11yID.autonomosControlReceipt)
    }
}

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
