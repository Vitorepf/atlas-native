import AtlasCore
import SwiftUI

// IDLE-COMPRESS peel ExecutionStateActionStyle (canon §7 · same domain)

extension ExecutionStateActionStyle {
    var border: Color {
        style == .destructive ? AtlasTheme.domOperacional.opacity(0.55) : AtlasTheme.separator
    }
}

extension ExecutionStateActionStyle {
    var background: Color {
        switch style {
        case .primary: return AtlasTheme.accent
        case .secondary: return AtlasTheme.surfaceHi
        case .destructive: return AtlasTheme.domOperacional.opacity(0.2)
        }
    }
}

extension ExecutionStateActionStyle {
    var foreground: Color {
        style == .primary ? AtlasTheme.bg : AtlasTheme.textPrimary
    }
}

struct ExecutionStateActionStyle: ButtonStyle {
    let style: AtlasExecutionPresentationState.ActionStyle
    var reduceMotion: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(foreground)
            .background(Capsule().fill(background.opacity(configuration.isPressed ? 0.72 : 1)))
            .overlay(Capsule().stroke(border, lineWidth: 1))
            .scaleEffect(reduceMotion ? 1 : (configuration.isPressed ? 0.97 : 1))
            .animation(
                reduceMotion ? nil : .easeOut(duration: AtlasMotion.instinct),
                value: configuration.isPressed
            )
    }
}
