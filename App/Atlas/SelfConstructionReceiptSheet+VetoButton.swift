import SwiftUI
import AtlasCore

// Botão veto — peel de SelfConstructionReceiptSheet+Veto.

extension SelfConstructionReceiptSheet {
    var vetoSubmitButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onRevert(actor, reason)
        } label: {
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
        .buttonStyle(PressableScale())
        .disabled(!canSubmitRevert)
        .accessibilityIdentifier(A11yID.selfReceiptVeto)
        .accessibilityLabel(spokenVetoSubmitLabel(canSubmit: canSubmitRevert))
        .accessibilityHint(spokenVetoSubmitHint(canSubmit: canSubmitRevert))
    }
}
