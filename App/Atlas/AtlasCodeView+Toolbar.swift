import SwiftUI
import AtlasCore

// Masthead do grafo: título Fraunces no principal.
// Repo glass vive no safeAreaInset (tap confiável — toolbar .principal
// clipava a pílula fora da hit-area da nav bar).

extension AtlasCodeView {
    var codeToolbar: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("Grafo")
                .font(AtlasFont.serif(20))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
        }
    }

    /// Troca de repositório — Liquid Glass, sempre abaixo do título.
    var repoSwitcher: some View {
        Button {
            showsRepoPicker = true
        } label: {
            HStack(spacing: 5) {
                Text(model.repo)
                    .font(AtlasFont.mono(10.5))
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(.system(size: 8, weight: .semibold))
                    .opacity(0.55)
            }
            .foregroundStyle(AtlasTheme.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .atlasGlassCapsule()
        }
        .buttonStyle(.plain)
        .accessibilityLabel("repositório \(model.repo)")
        .accessibilityHint("troca de repositório")
        .accessibilityIdentifier(A11yID.codeRepoSwitcher)
    }
}
