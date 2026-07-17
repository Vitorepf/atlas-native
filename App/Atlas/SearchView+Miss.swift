import SwiftUI
import AtlasCore

// Search miss empty — peel de SearchView+List.

struct SearchMissEmpty: View {
    let query: String
    let loadedThreadCount: Int

    var body: some View {
        VStack(spacing: 14) {
            Text("✦")
                .font(AtlasFont.serif(24)).foregroundStyle(AtlasTheme.accent.opacity(0.45))
            Text(loadedThreadCount >= 100
                 ? "“Nada com ‘\(query)’ nas 100 conversas mais recentes.”"
                 : "“Nada com ‘\(query)’.”")
                .font(AtlasFont.serifItalic(17)).foregroundStyle(AtlasTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity).padding(.top, 72).padding(.horizontal, 40)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(A11yID.searchEmpty)
    }
}
