import Foundation
import AtlasCore

// Row registration/selection spoken — peel de AutonomosAreaPicker+A11yRow.

extension AutonomosAreaPickerA11y {
    static func spokenRowRegistration(_ area: AtlasAutonomosArea, isSelected: Bool) -> [String] {
        var parts: [String] = []
        parts.append(AutonomosAreaPickerA11yPhase.spokenPhase(area.loopStatus.phase))
        if !area.registered { parts.append("não registrada no servidor") }
        if isSelected { parts.append("selecionada") }
        return parts
    }
}
