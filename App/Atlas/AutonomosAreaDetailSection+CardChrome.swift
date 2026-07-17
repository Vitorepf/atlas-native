import SwiftUI
import AtlasCore

// Card chrome — peel de AutonomosAreaDetailSection.

extension AutonomosAreaDetailSection {
    func areaDetailCardChrome<Content: View>(_ content: Content) -> some View {
        content
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 18).fill(AtlasTheme.surface))
            .overlay(RoundedRectangle(cornerRadius: 18).stroke(AtlasTheme.separator, lineWidth: 1))
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(A11yID.autonomosAreaDetailSection)
    }
}
