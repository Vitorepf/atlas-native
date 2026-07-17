import SwiftUI
import AtlasCore

// Header — peel de WorkspaceView (régua ~120).
// Filter + newPill → WorkspaceView+ChromeFilter.swift

extension WorkspaceView {
    var header: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                    .frame(width: 40, height: 40).background(Circle().fill(AtlasTheme.surface))
            }
            .accessibilityLabel("voltar")
            Spacer()
            Text(title)
                .font(AtlasFont.serif(20, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(1)
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel(headerSpokenTitle)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 4).padding(.bottom, 4)
    }

    var headerSpokenTitle: String {
        if freeOnly { return "conversas sem projeto" }
        return title
    }
}
