import SwiftUI
import AtlasCore

// Back control — peel de SearchView+Header.

extension SearchViewHeader {
    var searchBackButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            dismiss()
        } label: {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                .frame(width: 40, height: 40).background(Circle().fill(AtlasTheme.surface))
        }
        .accessibilityLabel("voltar")
        .accessibilityHint("fecha a busca")
    }
}
