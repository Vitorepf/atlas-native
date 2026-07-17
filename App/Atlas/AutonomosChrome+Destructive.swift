import SwiftUI

// Destructive style — peel de AutonomosChrome+Buttons.

struct AutonomosDestructiveButtonStyle: ButtonStyle {
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(.footnote, weight: .semibold)).foregroundStyle(AtlasTheme.domOperacional)
            .padding(.horizontal, 14).padding(.vertical, 9)
            .background(Capsule().fill(AtlasTheme.domOperacional.opacity(0.1)))
            .overlay(Capsule().stroke(AtlasTheme.domOperacional.opacity(0.45), lineWidth: 1))
            .opacity(configuration.isPressed && !reduceMotion ? 0.88 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.12), value: configuration.isPressed)
    }
}
