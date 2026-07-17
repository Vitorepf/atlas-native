import Foundation

// Autonomos area picker A11yIDs — peel de A11yID+AutonomosControl.

extension A11yID {
    static let autonomosAreaPicker = "autonomos-area-picker"
    static let autonomosAreaPickerRowPrefix = "autonomos-area-picker-row-"
    static func autonomosAreaPickerRow(_ index: Int) -> String { autonomosAreaPickerRowPrefix + String(index) }
    static let autonomosAreaDetailSection = "autonomos-area-detail-section"
}
