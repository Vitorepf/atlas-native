import SwiftUI
import AtlasCore

// Failure — peel de AtlasArenaView+States.
// Exception → AtlasArenaView+Exception.swift

extension AtlasArenaView {
    var networkFailureCard: some View {
        let kind = model.loadFailureKind
        let hasToken = session.hasToken
        return VStack(alignment: .leading, spacing: 10) {
            Text(AtlasFailureCopy.headline(kind: kind, hasToken: hasToken))
                .font(AtlasFont.serif(18, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityHidden(true)
            Text(AtlasFailureCopy.hint(kind: kind, hasToken: hasToken))
                .font(.system(.subheadline))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineSpacing(4)
                .accessibilityHidden(true)
            if hasToken {
                Button {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    Task { await model.load() }
                } label: {
                    Text("Tentar de novo")
                        .font(AtlasFont.serifItalic(15))
                        .foregroundStyle(AtlasTheme.accent)
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
                .accessibilityLabel("tentar de novo")
                .accessibilityHint("reconecta ao servidor Atlas")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .atlasCard()
        .accessibilityElement(children: .contain)
        .accessibilityLabel("\(AtlasFailureCopy.headline(kind: kind, hasToken: hasToken)). \(AtlasFailureCopy.hint(kind: kind, hasToken: hasToken))")
    }
}
