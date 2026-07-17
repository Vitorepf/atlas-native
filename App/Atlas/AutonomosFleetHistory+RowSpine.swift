import SwiftUI
import AtlasCore

// Spine visual do history row — peel de AutonomosFleetHistory+Row.

extension AutonomosFleetHistorySection {
    func historyEventSpine(index: Int, visibleCount: Int) -> some View {
        VStack(spacing: 0) {
            Circle()
                .fill(index == 0 ? AtlasTheme.accent : AtlasTheme.accent.opacity(0.35))
                .frame(width: 7, height: 7)
                .padding(.top, 5)
            if index < visibleCount - 1 {
                Rectangle()
                    .fill(AtlasTheme.accent.opacity(0.18))
                    .frame(width: 1.5, height: 34)
            }
        }
        .accessibilityHidden(true)
    }
}
