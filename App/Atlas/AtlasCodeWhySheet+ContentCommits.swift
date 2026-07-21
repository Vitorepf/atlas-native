import SwiftUI
import AtlasCore

/// Commits carregados — peel de AtlasCodeWhySheet+Content.

extension AtlasCodeWhySheet {
    @ViewBuilder
    func whyLoadedCommits(_ why: AtlasCodeWhy) -> some View {
        if why.commits.isEmpty {
            Text("este arquivo não tem história neste recorte")
                .font(AtlasFont.serifItalic(16))
                .foregroundStyle(AtlasTheme.textTertiary)
                .padding(.top, 6)
                .accessibilityLabel(spokenEmptyHistory())
        } else {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(why.commits.enumerated()), id: \.element.id) { index, commit in
                    whyRow(commit, index: index, isLast: index == why.commits.count - 1)
                }
            }
        }
    }
}
