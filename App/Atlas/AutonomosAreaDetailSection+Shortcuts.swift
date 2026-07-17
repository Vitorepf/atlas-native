import SwiftUI
import AtlasCore

// Atalhos de detalhes públicos — peel de AutonomosAreaDetailSection.
// Chips → AutonomosAreaDetailSection+ShortcutChips.swift

extension AutonomosAreaDetailSection {
    @ViewBuilder
    var backlogDetailShortcuts: some View {
        if let backlog = model.backlog {
            VStack(alignment: .leading, spacing: 7) {
                Text("DETALHES PÚBLICOS")
                    .font(AtlasFont.mono(10)).tracking(0.9)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                backlogChipRow(backlog)
            }
        }
    }
}
