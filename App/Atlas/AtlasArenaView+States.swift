import SwiftUI
import AtlasCore

// Estados vazio/erro/carregando — peel de AtlasArenaView (régua ~160).

extension AtlasArenaView {
    var loadingCard: some View {
        TraceEvidenceLoading(text: "carregando índice medido…", reduceMotion: reduceMotion)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .atlasCard()
    }

    func stateCard(_ message: String) -> some View {
        Text(message)
            .font(.system(.subheadline))
            .foregroundStyle(AtlasTheme.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .atlasCard()
            .accessibilityLabel(message)
    }

    var networkFailureCard: some View {
        let kind = model.loadFailureKind
        let hasToken = session.hasToken
        return VStack(alignment: .leading, spacing: 10) {
            Text(AtlasFailureCopy.headline(kind: kind, hasToken: hasToken))
                .font(AtlasFont.serif(18, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
            Text(AtlasFailureCopy.hint(kind: kind, hasToken: hasToken))
                .font(.system(.subheadline))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineSpacing(4)
            if hasToken {
                Button {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    Task { await model.load() }
                } label: {
                    Text("Tentar de novo")
                        .font(AtlasFont.serifItalic(15))
                        .foregroundStyle(AtlasTheme.accent)
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
                .accessibilityHint("reconecta ao servidor Atlas")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .atlasCard()
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(AtlasFailureCopy.headline(kind: kind, hasToken: hasToken)). \(AtlasFailureCopy.hint(kind: kind, hasToken: hasToken))")
    }

    func exceptionBanner(_ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(AtlasTheme.alert)
            Text(text)
                .font(.system(.callout, weight: .medium))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(2)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14).fill(AtlasTheme.alert.opacity(0.10)))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AtlasTheme.alert.opacity(0.35), lineWidth: 1))
    }
}
