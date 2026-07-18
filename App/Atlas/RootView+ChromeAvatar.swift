import SwiftUI
import AtlasCore

// Avatar do topBar — peel de RootView+Chrome.

extension RootView {
    var topBarAvatar: some View {
        Circle()
            .fill(AtlasTheme.surface)
            .frame(width: 44, height: 44)
            .overlay(Image(systemName: "person.fill").atlasSans(18).foregroundStyle(AtlasTheme.textSecondary))
            .overlay(Circle().stroke(AtlasTheme.separator, lineWidth: 1))
            .accessibilityHidden(true)
    }
}
