import SwiftUI
import AtlasCore

// Control receipt — peel de AutonomosLoadedSection+Lines.
// Error → AutonomosLoadedSection+ErrorCard.swift

struct AutonomosControlReceiptLine: View {
    let receipt: AtlasAutonomosRunControlResponse

    var body: some View {
        Text(receipt.note)
            .font(.footnote).foregroundStyle(AtlasTheme.textSecondary)
            .padding(12).frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control).fill(AtlasTheme.domAutonomos.opacity(0.1)))
            .accessibilityLabel(AutonomosLoadedSectionA11y.spokenControlReceipt(receipt))
            .accessibilityAddTraits(.isStaticText)
            .accessibilityIdentifier(A11yID.autonomosControlReceipt)
    }
}
