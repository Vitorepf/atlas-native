import SwiftUI
import AtlasCore

// Objective + divider — peel de AutonomosAreaDetailSection+Body.

extension AutonomosAreaDetailSection {
    @ViewBuilder
    var areaObjectiveBlock: some View {
        Text(area.objective)
            .font(.footnote)
            .foregroundStyle(AtlasTheme.textSecondary)
            .lineLimit(objectiveExpanded ? nil : 3)
            .contentShape(Rectangle())
            .onTapGesture {
                if reduceMotion { objectiveExpanded.toggle() } else {
                    withAnimation(.easeOut(duration: 0.2)) { objectiveExpanded.toggle() }
                }
            }
            .accessibilityLabel(area.objective)
            .accessibilityHint(objectiveExpanded ? "toque para recolher" : "toque para ler o objetivo inteiro")
        Divider()
            .overlay(AtlasTheme.separatorSoft)
            .accessibilityHidden(true)
    }
}
