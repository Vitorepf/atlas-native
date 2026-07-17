import SwiftUI
import AtlasCore

// Status indicator — peel de ArenaNowSection.

extension ArenaNowSection {
    @ViewBuilder
    func statusIndicator(for run: AtlasArenaLiveRun) -> some View {
        Group {
            if case .running = run.status {
                BreathingDiamond(size: 8, reduceMotion: reduceMotion)
            } else {
                Circle()
                    .fill(AtlasTheme.textTertiary)
            }
        }
        .frame(width: 8, height: 8)
        .accessibilityHidden(true)
    }
}
