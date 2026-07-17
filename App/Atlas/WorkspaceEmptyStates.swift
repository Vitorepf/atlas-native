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

struct WorkspaceNetworkFailureEmpty: View {
    let kind: AtlasNetworkFailureKind?
    let hasToken: Bool
    let host: String
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
                Button {
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
                .accessibilityHint("reconecta ao servidor Atlas")
            }
        }
        .padding(.horizontal, 44).padding(.top, 56)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(A11yID.workspaceOffline)
        .accessibilityLabel("\(AtlasFailureCopy.headline(kind: kind, hasToken: hasToken)). \(AtlasFailureCopy.hint(kind: kind, hasToken: hasToken))")
    }
}

struct WorkspaceEditorialEmpty: View {
    let area: AtlasArea
    let freeOnly: Bool

    var body: some View {
        VStack(spacing: 14) {
            Text("✦")
                .font(AtlasFont.serif(24)).foregroundStyle(AtlasTheme.accent.opacity(0.45))
            Text(area == .tudo
                 ? "“Nenhuma conversa aqui ainda.”"
                 : "“Nada em \(area.label) — por enquanto.”")
                .font(AtlasFont.serifItalic(17)).foregroundStyle(AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
            Text(freeOnly
                 ? "perguntas e pensamento livre começam abaixo"
                 : "comece uma abaixo — o projeto é opcional")
                .font(.system(.footnote)).foregroundStyle(AtlasTheme.textTertiary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding(.top, 72).padding(.horizontal, 40)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(A11yID.workspaceEmpty)
    }
}
