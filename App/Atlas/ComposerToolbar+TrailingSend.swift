import SwiftUI
import AtlasCore

// Send / processing trailing — peel de ComposerToolbar+Trailing.

extension ComposerToolbar {
    var trailingSendButton: some View {
        Button(action: onSend) {
            Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 29))
                .foregroundStyle(AtlasTheme.accent)
                .frame(width: 32, height: 32)
        }
        .buttonStyle(.plain)
        .keyboardShortcut(.return, modifiers: .command)
        .accessibilityLabel(spokenSendLabel(canSubmit: true))
        .accessibilityHint(spokenSendHint(canSubmit: true))
        .accessibilityIdentifier(A11yID.conversationSend)
    }

    var trailingProcessing: some View {
        ZStack {
            BreathingDiamond(size: 13, reduceMotion: reduceMotion)
                .accessibilityHidden(true)
            Image(systemName: "arrow.up.circle.fill")
                .font(.system(size: 29))
                .foregroundStyle(AtlasTheme.textTertiary.opacity(0.38))
                .accessibilityHidden(true)
        }
        .frame(width: 32, height: 32)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(spokenProcessingLabel()), \(spokenSendLabel(canSubmit: false))")
        .accessibilityHint(spokenSendHint(canSubmit: false))
        .accessibilityIdentifier(A11yID.conversationSend)
    }
}
