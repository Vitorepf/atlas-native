import SwiftUI
import AtlasCore

// New badge — peel de RootChrome+ThreadRow+TrailingStatus.

extension ThreadRow {
    @ViewBuilder
    var newThreadBadge: some View {
        if isNew && !isRunning {
            Text("novo")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.accent)
                .padding(.horizontal, 7)
                .padding(.vertical, 3)
                .background(Capsule().fill(AtlasTheme.goldVeil))
                .accessibilityHidden(true)
        }
    }
}
