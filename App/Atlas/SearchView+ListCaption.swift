import SwiftUI
import AtlasCore

// Recent caption — peel de SearchView+List.

extension SearchRecentSection {
    var recentCaption: some View {
        Text("RECENTES")
            .font(AtlasFont.mono(10, .semibold)).tracking(1.4)
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AtlasTheme.Space.screen).padding(.bottom, 8)
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel("recentes, \(threads.count) conversa\(threads.count == 1 ? "" : "s") carregada\(threads.count == 1 ? "" : "s")")
            .accessibilityIdentifier(A11yID.searchRecentCaption)
    }
}
