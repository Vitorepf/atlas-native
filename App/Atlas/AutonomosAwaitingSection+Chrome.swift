import SwiftUI
import AtlasCore

// Chrome visual awaiting — peel de AutonomosAwaitingSection.

extension AutonomosAwaitingYouSection {
    var awaitingChrome: some View {
        VStack(alignment: .leading, spacing: 10) {
            awaitingHeader
            Text("Há decisão pública pendente; nada aqui afirma execução antes do recibo do owner.")
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
            awaitingChips
        }
        .padding(14)
        .background(RoundedRectangle(cornerRadius: 14).fill(AtlasTheme.domOperacional.opacity(0.08)))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AtlasTheme.domOperacional.opacity(0.38), lineWidth: 1))
    }
}
