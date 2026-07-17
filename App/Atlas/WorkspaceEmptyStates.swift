import SwiftUI
import AtlasCore

// Estados vazios do WorkspaceView (loading / offline / editorial) —
// peel anti-inchaço; voz partilhada com a home via AtlasFailureCopy.

struct WorkspaceLoadingEmpty: View {
    var reduceMotion: Bool

    var body: some View {
        VStack(spacing: 18) {
            BreathingGlyph(reduceMotion: reduceMotion)
            Text("abrindo conversas…")
                .font(AtlasFont.serifItalic(15)).foregroundStyle(AtlasTheme.textTertiary)
        }
        .frame(maxWidth: .infinity).padding(.top, 72)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("abrindo conversas")
    }
}

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

    var body: some View {
        VStack(spacing: 0) {
            Text("✦")
                .font(AtlasFont.serif(28)).foregroundStyle(AtlasTheme.accent.opacity(0.55))
            Spacer().frame(height: 28)
            Text(AtlasFailureCopy.headline(kind: kind, hasToken: hasToken))
                .font(AtlasFont.serif(22, .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                .multilineTextAlignment(.center)
            Spacer().frame(height: 12)
            Text(hasToken ? "\(host):3737" : "ATLAS_TOKEN · Secrets.xcconfig")
                .font(AtlasFont.mono(12)).foregroundStyle(AtlasTheme.textTertiary)
            Spacer().frame(height: 16)
            Text(AtlasFailureCopy.hint(kind: kind, hasToken: hasToken))
                .font(.system(.subheadline)).lineSpacing(5)
                .foregroundStyle(AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
            if hasToken {
                Spacer().frame(height: 28)
                retryButton
            }
        }
        .padding(.horizontal, 44).padding(.top, topPadding)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(accessibilityIdentifier)
        .accessibilityLabel("\(AtlasFailureCopy.headline(kind: kind, hasToken: hasToken)). \(AtlasFailureCopy.hint(kind: kind, hasToken: hasToken))")
    }

    @ViewBuilder
    private var retryButton: some View {
        let button = Button {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            onRetry()
        } label: {
            Text("Tentar de novo")
                .font(AtlasFont.serifItalic(16)).foregroundStyle(AtlasTheme.accent)
                .padding(.horizontal, 22).padding(.vertical, 10)
                .background(Capsule().fill(AtlasTheme.goldVeil)
                    .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
        }
        .buttonStyle(PressableScale())
        .accessibilityHint(retryHint)

        if let retryAccessibilityIdentifier {
            button.accessibilityIdentifier(retryAccessibilityIdentifier)
        } else {
            button
        }
    }
}

struct WorkspaceEditorialEmpty: View {
    let area: AtlasArea
    let freeOnly: Bool
    let screenTitle: String

    private var headline: String {
        if area != .tudo {
            return "“Nada em \(area.label) — por enquanto.”"
        }
        if freeOnly {
            return "“Nenhuma conversa sem projeto ainda.”"
        }
        return "“Nenhuma conversa em \(screenTitle) ainda.”"
    }

    private var footnote: String {
        if freeOnly {
            return "perguntas e pensamento livre começam abaixo"
        }
        return "comece uma abaixo — o projeto é opcional"
    }

    private var spokenLabel: String {
        let lead: String
        if area != .tudo {
            lead = "nada em \(area.label) em \(screenTitle)"
        } else if freeOnly {
            lead = "nenhuma conversa sem projeto ainda"
        } else {
            lead = "nenhuma conversa em \(screenTitle) ainda"
        }
        return "\(lead). \(footnote)"
    }

    var body: some View {
        VStack(spacing: 14) {
            Text("✦")
                .font(AtlasFont.serif(24)).foregroundStyle(AtlasTheme.accent.opacity(0.45))
            Text(headline)
                .font(AtlasFont.serifItalic(17)).foregroundStyle(AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
            Text(footnote)
                .font(.system(.footnote)).foregroundStyle(AtlasTheme.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding(.top, 72).padding(.horizontal, 40)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(spokenLabel)
        .accessibilityIdentifier(A11yID.workspaceEmpty)
    }
}
