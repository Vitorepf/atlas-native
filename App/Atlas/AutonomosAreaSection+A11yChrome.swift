import SwiftUI

// Area controls a11y — peel de AutonomosAreaSection.

extension AutonomosAreaControls {
    func areaControlsA11yChrome<Content: View>(_ content: Content) -> some View {
        content
            .disabled(!canControl)
            .accessibilityElement(children: .contain)
            .accessibilityLabel(spokenContainerLabel)
            .accessibilityHint(spokenContainerHint)
            .accessibilityIdentifier(A11yID.autonomosAreaControls)
    }
}
