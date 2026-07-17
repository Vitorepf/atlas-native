import Foundation
import AtlasCore

/// Spoken row — peel de AutonomosAreaPicker+A11y.
/// Phase → AutonomosAreaPicker+A11yPhase.swift
/// Hint → AutonomosAreaPicker+A11yRowHint.swift

extension AutonomosAreaPickerA11y {
    static func spokenRow(
        _ area: AtlasAutonomosArea,
        index: Int,
        total: Int,
        isSelected: Bool
    ) -> String {
        var parts = ["instância \(index + 1) de \(total)", area.areaName]
        let objective = area.objective.trimmingCharacters(in: .whitespacesAndNewlines)
        if !objective.isEmpty { parts.append(objective) }
        parts.append(AutonomosAreaPickerA11yPhase.spokenPhase(area.loopStatus.phase))
        if !area.registered { parts.append("não registrada no servidor") }
        if isSelected { parts.append("selecionada") }
        return parts.joined(separator: ", ")
    }
}
