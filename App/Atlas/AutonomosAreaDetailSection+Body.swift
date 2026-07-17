import SwiftUI
import AtlasCore

// Stack body — peel de AutonomosAreaDetailSection.
// Header/métricas → AutonomosAreaDetailSection+Header.swift
// Controls → AutonomosAreaDetailSection+Controls.swift
// Counts → AutonomosAreaDetailSection+Counts.swift
// Objective → AutonomosAreaDetailSection+Objective.swift

extension AutonomosAreaDetailSection {
    var areaDetailBody: some View {
        VStack(alignment: .leading, spacing: 16) {
            areaDetailUpperStack
            areaDetailLowerStack
        }
    }
}
