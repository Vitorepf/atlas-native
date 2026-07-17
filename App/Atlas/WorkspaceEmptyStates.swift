import SwiftUI
import AtlasCore

// Estados vazios do WorkspaceView (offline) —
// peel anti-inchaço; voz partilhada com a home via AtlasFailureCopy.
// Loading → WorkspaceEmptyStates+Loading · Editorial → +Editorial.

/// Falha de rede compartilhada — home, workspace e conversa (voz via `AtlasFailureCopy`).
struct AtlasNetworkFailureEmpty: View {
    let kind: AtlasNetworkFailureKind?
    let hasToken: Bool
    let host: String
    var topPadding: CGFloat = 56
    var retryHint: String = "reconecta ao servidor Atlas"
    var retryAccessibilityIdentifier: String?
    let accessibilityIdentifier: String
    let onRetry: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 0) {
            Text("✦")
                .font(AtlasFont.serif(28)).foregroundStyle(AtlasTheme.accent.opacity(0.55))
                .accessibilityHidden(true)
            Spacer().frame(height: 28)
            Text(AtlasFailureCopy.headline(kind: kind, hasToken: hasToken))
                .font(AtlasFont.serif(22, .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                .multilineTextAlignment(.center)
                .accessibilityHidden(true)
            Spacer().frame(height: 12)
            Text(hasToken ? "\(host):3737" : "ATLAS_TOKEN · Secrets.xcconfig")
                .font(AtlasFont.mono(12)).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Spacer().frame(height: 16)
            Text(AtlasFailureCopy.hint(kind: kind, hasToken: hasToken))
                .font(.system(.subheadline)).lineSpacing(5)
                .foregroundStyle(AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
                .accessibilityHidden(true)
            if hasToken {
                Spacer().frame(height: 28)
                retryButton
            }
        }
        .padding(.horizontal, 44).padding(.top, topPadding)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(accessibilityIdentifier)
        .accessibilityLabel("\(AtlasFailureCopy.headline(kind: kind, hasToken: hasToken)). \(AtlasFailureCopy.hint(kind: kind, hasToken: hasToken))")
    }

    @ViewBuilder
    private var retryButton: some View {
        let button = Button {
            if !reduceMotion { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
            onRetry()
        } label: {
            Text("Tentar de novo")
                .font(AtlasFont.serifItalic(16)).foregroundStyle(AtlasTheme.accent)
                .padding(.horizontal, 22).padding(.vertical, 10)
                .background(Capsule().fill(AtlasTheme.goldVeil)
                    .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel("tentar de novo")
        .accessibilityHint(retryHint)

        if let retryAccessibilityIdentifier {
            button.accessibilityIdentifier(retryAccessibilityIdentifier)
        } else {
            button
        }
    }
}
