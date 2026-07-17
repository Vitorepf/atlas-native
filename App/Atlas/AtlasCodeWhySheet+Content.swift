import SwiftUI
import AtlasCore

/// Estados loading/failed/loaded — peel de AtlasCodeWhySheet (régua ≤100).
/// Loading/failed → AtlasCodeWhySheet+Loading.swift

extension AtlasCodeWhySheet {
    @ViewBuilder var content: some View {
        switch model.phase {
        case .idle, .loading, .failed:
            whyLoadingOrFailed
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
