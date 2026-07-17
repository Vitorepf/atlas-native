import SwiftUI
import AtlasCore

// Objective + divider — peel de AutonomosAreaDetailSection+Body.

extension AutonomosAreaDetailSection {
    @ViewBuilder
    var areaObjectiveBlock: some View {
        Text(area.objective)
            .font(.footnote)
            .foregroundStyle(AtlasTheme.textSecondary)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityHidden(true)
        Divider()
            .overlay(AtlasTheme.separatorSoft)
            .accessibilityHidden(true)
    }
}
