import SwiftUI
import AtlasCore

// Stack body — peel de AutonomosAreaDetailSection.
// Header/métricas → AutonomosAreaDetailSection+Header.swift
// Controls → AutonomosAreaDetailSection+Controls.swift
// Counts → AutonomosAreaDetailSection+Counts.swift

extension AutonomosAreaDetailSection {
    var areaDetailBody: some View {
        VStack(alignment: .leading, spacing: 16) {
            areaHeader
            Text(area.objective).font(.footnote).foregroundStyle(AtlasTheme.textSecondary).fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
            Divider().overlay(AtlasTheme.separatorSoft).accessibilityHidden(true)
            metricsRow
            backlogDetailShortcuts
            placementSection
            AutonomosAreaDeliveredSection(
                area: area,
                model: model,
                onSelfConstructionReceipt: onSelfConstructionReceipt
            )
            ownedSystemsBlock
            areaControls
        }
    }
}
