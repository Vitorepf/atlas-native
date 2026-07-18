import SwiftUI
import AtlasCore

// Chrome visual awaiting — peel de AutonomosAwaitingSection.

extension AutonomosAwaitingYouSection {
    var awaitingChrome: some View {
        VStack(alignment: .leading, spacing: 10) {
            awaitingHeader
            // Copy fala ao operador, não a linguagem de governança do sistema.
            Text("Decisões que só você pode tomar.")
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
