import SwiftUI
import AtlasCore

extension RootHomeSections {
    @ViewBuilder
    var failureSection: some View {
        centered {
            VStack(spacing: 0) {
                Text("✦")
                    .font(AtlasFont.serif(28)).foregroundStyle(AtlasTheme.accent.opacity(0.55))
                Spacer().frame(height: 28)
                Text(failureHeadline)
                    .font(AtlasFont.serif(22, .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                    .multilineTextAlignment(.center)
                Spacer().frame(height: 12)
                Text(session.hasToken ? "\(session.host):3737" : "ATLAS_TOKEN · Secrets.xcconfig")
                    .font(AtlasFont.mono(12)).foregroundStyle(AtlasTheme.textTertiary)
                Spacer().frame(height: 16)
                Text(failureHint)
                    .font(.system(.subheadline)).lineSpacing(5)
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .multilineTextAlignment(.center)
                if session.hasToken {
                    Spacer().frame(height: 28)
                    Button {
                        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                        Task { await session.loadThreads() }
                    } label: {
                        Text("Tentar de novo")
                            .font(AtlasFont.serifItalic(16)).foregroundStyle(AtlasTheme.accent)
                            .padding(.horizontal, 22).padding(.vertical, 10)
                            .background(Capsule().fill(AtlasTheme.goldVeil)
                                .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
                    }
                    .buttonStyle(PressableScale())
                    .accessibilityHint("reconecta ao servidor Atlas")
                    .accessibilityIdentifier(A11yID.homeRetry)
                }
            }
            .padding(.horizontal, 44)
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier(A11yID.homeOffline)
            .accessibilityLabel("\(failureHeadline). \(failureHint)")
        }
    }

    var failureHeadline: String {
        AtlasFailureCopy.headline(kind: session.failureKind, hasToken: session.hasToken)
    }

    var failureHint: String {
        AtlasFailureCopy.hint(kind: session.failureKind, hasToken: session.hasToken)
    }
}
