import SwiftUI
import AtlasCore

// Veto button label — peel de SelfConstructionReceiptSheet+VetoButton.

extension SelfConstructionReceiptSheet {
    var vetoSubmitLabel: some View {
        HStack(spacing: 7) {
            Image(systemName: "arrow.uturn.backward")
                .accessibilityHidden(true)
            Text("Desfazer — com recibo")
        }
        .font(.system(size: 14, weight: .medium))
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .foregroundStyle(AtlasTheme.domOperacional)
        .atlasCard(cornerRadius: 13)
    }
}
