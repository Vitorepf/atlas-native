import SwiftUI
import AtlasCore

// Secondary button style — peel de AutonomosChrome+Buttons.

struct AutonomosSecondaryButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(.footnote, weight: .semibold)).foregroundStyle(AtlasTheme.textPrimary)
            .padding(.horizontal, 14).padding(.vertical, 9)
            .background(Capsule().fill(AtlasTheme.surfaceHi))
            .overlay(Capsule().stroke(AtlasTheme.separator, lineWidth: 1))
            .opacity(configuration.isPressed && !reduceMotion ? 0.88 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
