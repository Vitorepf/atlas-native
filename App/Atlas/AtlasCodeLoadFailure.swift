import SwiftUI

/// Falha de carregamento Código — canônico (radar + grafo).
struct AtlasCodeLoadFailureEmpty: View {
    let headline: String
    let message: String
    let onRetry: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 24))
                .foregroundStyle(AtlasCodePalette.alert)
                .accessibilityHidden(true)
            Text(headline)
                .font(AtlasFont.serif(20, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            Text(message)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
                .accessibilityHidden(true)
            Button {
                if !reduceMotion { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
                onRetry()
            } label: {
                Text("Tentar de novo")
            }
            .buttonStyle(.borderedProminent)
            .tint(AtlasTheme.accent)
            .accessibilityLabel("tentar de novo")
            .accessibilityHint("recarrega o grafo ou radar deste repositório")
            .accessibilityIdentifier(A11yID.codeLoadRetry)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(headline). \(message)")
        .accessibilityIdentifier(A11yID.codeLoadFailure)
    }
}
