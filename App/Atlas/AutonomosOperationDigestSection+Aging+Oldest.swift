import SwiftUI
import AtlasCore

// Oldest backlog — peel de AutonomosOperationDigestSection+Aging.

extension AutonomosOperationDigestSection {
    @ViewBuilder
    var digestOldestBacklog: some View {
        if let oldest = oldestBacklogCreatedAt {
            Text("item mais antigo · \(AutonomosChrome.relativeAge(from: oldest))")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.domOperacional)
                .monospacedDigit()
                .accessibilityHidden(true)
        }
    }
}
