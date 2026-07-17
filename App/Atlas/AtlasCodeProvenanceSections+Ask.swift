import SwiftUI
import AtlasCore

// Ask button — peel de AtlasCodeProvenanceSections.

extension AtlasCodeProvenanceSheet {
    /// A porta para o agente, com o commit já no assunto.
    var askButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onAsk()
        } label: {
            HStack(spacing: 8) {
                Text("✦")
                    .font(AtlasFont.serif(12))
                    .foregroundStyle(AtlasTheme.accent)
                    .accessibilityHidden(true)
                Text("perguntar sobre este commit")
                    .font(AtlasFont.serifItalic(14))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .accessibilityHidden(true)
                Spacer(minLength: 0)
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .atlasCard(cornerRadius: 12)
            .contentShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(PressableScale())
        .accessibilityIdentifier(A11yID.codeProvenanceAsk)
        .accessibilityLabel("perguntar ao Atlas sobre este commit")
        .accessibilityHint(Self.askHint)
    }
}
