import SwiftUI
import AtlasCore

// Row label chrome — peel de AutonomosAreaPicker+RowLabel.

extension AutonomosAreaPicker {
    func areaRowLabelChrome<Content: View>(_ content: Content, isSelected: Bool) -> some View {
        content
            .padding(12)
            .background(RoundedRectangle(cornerRadius: 12).fill(isSelected ? AtlasTheme.surfaceHi : AtlasTheme.surface))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(isSelected ? AtlasTheme.goldBorder : AtlasTheme.separatorSoft, lineWidth: 1))
    }
}
