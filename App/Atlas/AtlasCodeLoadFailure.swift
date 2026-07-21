import SwiftUI

// Cycle 043 fuse → AtlasCodeLoadFailure.swift

/// Falha de carregamento Código — canônico (radar + grafo).
struct AtlasCodeLoadFailureEmpty: View {
    let headline: String
    let message: String
    let onRetry: () -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .atlasSans(24)
                .foregroundStyle(AtlasCodePalette.alert)
                .accessibilityHidden(true)
            Text(headline)
                .font(AtlasFont.serif(20, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Text(message)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onRetry()
            } label: {
                Text("Tentar de novo")
                    .font(AtlasFont.serifItalic(16))
                    .foregroundStyle(AtlasTheme.accent)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 12)
                    .frame(minHeight: 48)
                    .background(
                        Capsule().fill(AtlasTheme.goldVeil)
                            .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1))
                    )
                    .contentShape(Capsule())
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel("tentar de novo")
            .accessibilityHint("recarrega o grafo ou radar deste repositório")
            .accessibilityIdentifier(A11yID.codeLoadRetry)
            .accessibilityAddTraits(.isButton)
            .accessibilitySortPriority(8)
        }
        .padding(.horizontal, 28)
        .frame(maxWidth: 420, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.codeLoadFailure)
    }
}
