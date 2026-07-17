import Foundation
import AtlasCore

/// Spoken row — peel de AutonomosAreaPicker+A11y.
/// Phase → AutonomosAreaPicker+A11yPhase.swift
/// Hint → AutonomosAreaPicker+A11yRowHint.swift
/// Identity → AutonomosAreaPicker+A11yRowIdentity.swift
/// Registration → AutonomosAreaPicker+A11yRowRegistration.swift

extension AutonomosAreaPickerA11y {
    static func spokenRow(
        _ area: AtlasAutonomosArea,
        index: Int,
        total: Int,
        isSelected: Bool
    ) -> String {
        var parts = spokenRowIdentity(area, index: index, total: total)
        parts.append(contentsOf: spokenRowRegistration(area, isSelected: isSelected))
        return parts.joined(separator: ", ")
    }
}
