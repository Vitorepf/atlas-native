import SwiftUI
import AtlasCore

struct AutonomosPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(.footnote, weight: .semibold)).foregroundStyle(AtlasTheme.bg)
            .padding(.horizontal, 14).padding(.vertical, 9)
            .background(Capsule().fill(AtlasTheme.accent.opacity(configuration.isPressed ? 0.72 : 1)))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

struct AutonomosSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(.footnote, weight: .semibold)).foregroundStyle(AtlasTheme.textPrimary)
            .padding(.horizontal, 14).padding(.vertical, 9)
            .background(Capsule().fill(AtlasTheme.surfaceHi))
            .overlay(Capsule().stroke(AtlasTheme.separator, lineWidth: 1))
    }
}

struct AutonomosDestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.font(.system(.footnote, weight: .semibold)).foregroundStyle(AtlasTheme.domOperacional)
            .padding(.horizontal, 14).padding(.vertical, 9)
            .background(Capsule().fill(AtlasTheme.domOperacional.opacity(0.1)))
            .overlay(Capsule().stroke(AtlasTheme.domOperacional.opacity(0.45), lineWidth: 1))
    }
}
