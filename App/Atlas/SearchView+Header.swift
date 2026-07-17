import SwiftUI
import AtlasCore

struct SearchViewHeader: View {
    @Binding var query: String
    @FocusState.Binding var focused: Bool
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                    .frame(width: 40, height: 40).background(Circle().fill(AtlasTheme.surface))
            }
            .accessibilityLabel("voltar")

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15)).foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                ZStack(alignment: .leading) {
                    Text("Buscar conversas")
                        .font(AtlasFont.serifItalic(16)).foregroundStyle(AtlasTheme.textTertiary)
                        .opacity(query.isEmpty ? 1 : 0).allowsHitTesting(false)
                    TextField("", text: $query)
                        .font(.system(.callout)).foregroundStyle(AtlasTheme.textPrimary)
                        .tint(AtlasTheme.accent).focused($focused)
                        .submitLabel(.search)
                        .accessibilityLabel("buscar conversas")
                        .accessibilityIdentifier(A11yID.searchField)
                }
                if !query.isEmpty {
                    Button { query = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 15)).foregroundStyle(AtlasTheme.textTertiary)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("limpar busca")
                    .accessibilityIdentifier(A11yID.searchClear)
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 9)
            .background(Capsule().fill(AtlasTheme.surface)
                .overlay(Capsule().stroke(focused ? AtlasTheme.goldBorder : AtlasTheme.separator, lineWidth: 1)))
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 4).padding(.bottom, 10)
    }
}
