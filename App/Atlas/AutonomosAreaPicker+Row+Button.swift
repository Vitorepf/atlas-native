import SwiftUI
import AtlasCore

// Area row button — peel de AutonomosAreaPicker+Row.

extension AutonomosAreaPicker {
    func areaRowButton(area: AtlasAutonomosArea, isSelected: Bool) -> some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onSelect(area.id)
        } label: {
            areaRowLabel(area: area, isSelected: isSelected)
        }
        .buttonStyle(.plain)
    }
}
