import Foundation
import AtlasCore

// Row identity spoken — peel de AutonomosAreaPicker+A11yRow.

extension AutonomosAreaPickerA11y {
    static func spokenRowIdentity(
        _ area: AtlasAutonomosArea,
        index: Int,
        total: Int
    ) -> [String] {
        var parts = ["instância \(index + 1) de \(total)", area.areaName]
        let objective = area.objective.trimmingCharacters(in: .whitespacesAndNewlines)
        if !objective.isEmpty { parts.append(objective) }
        return parts
    }
}
