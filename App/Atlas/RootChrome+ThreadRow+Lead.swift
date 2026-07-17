import SwiftUI
import AtlasCore

// Thread lead icon — peel de RootChrome+ThreadRow+Content.

extension ThreadRow {
    @ViewBuilder
    var rowLead: some View {
        if isRunning {
            BreathingDiamond(size: 9, reduceMotion: reduceMotion).frame(width: 22)
                .accessibilityHidden(true)
        } else {
            Image(systemName: "bubble.left")
                .font(.system(size: 17)).foregroundStyle(AtlasTheme.textSecondary).frame(width: 22)
                .accessibilityHidden(true)
        }
    }
}
