import SwiftUI
import AtlasCore

/// Estados loading/failed/loaded — peel de AtlasCodeWhySheet (régua ≤100).

extension AtlasCodeWhySheet {
    @ViewBuilder var content: some View {
        switch model.phase {
        case .idle, .loading:
            HStack(spacing: 10) {
                BreathingDiamond(size: 10, reduceMotion: reduceMotion)
                    .accessibilityHidden(true)
                Text("lendo a história do arquivo…")
                    .font(AtlasFont.serifItalic(15))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            .padding(.top, 8)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenLoading())
        case .failed:
            VStack(alignment: .leading, spacing: 6) {
                Text("biografia indisponível")
                    .font(AtlasFont.serifItalic(16))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .accessibilityHidden(true)
                if let message = model.message, !message.isEmpty {
                    Text(message)
                        .font(AtlasFont.mono(9.5))
                        .foregroundStyle(AtlasCodePalette.alert)
                        .accessibilityHidden(true)
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenFailed())
        case .loaded:
            if let why = model.why, why.commits.isEmpty {
                Text("este arquivo não tem história neste recorte")
                    .font(AtlasFont.serifItalic(16))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .padding(.top, 6)
                    .accessibilityLabel(spokenEmptyHistory())
            } else if let why = model.why {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(why.commits.enumerated()), id: \.element.id) { index, commit in
                        whyRow(commit, index: index, isLast: index == why.commits.count - 1)
                    }
                }
            }
        }
    }
}
