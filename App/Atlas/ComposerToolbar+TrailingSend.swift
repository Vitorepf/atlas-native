import SwiftUI
import AtlasCore

// Send / processing trailing — peel de ComposerToolbar+Trailing.
// Processing → ComposerToolbar+TrailingProcessing.swift

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
}
