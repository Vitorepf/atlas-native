import AtlasCore
import SwiftUI

// Cycle 030 fuse → ComposerToolbar+Trailing.swift

extension ComposerToolbar {
    @ViewBuilder
    var trailingControlBranch: some View {
        if canSubmit {
            trailingSendButton
        } else if isExecuting {
            trailingProcessing
        } else {
            trailingOptionsMenu
        }
    }
}

extension ComposerToolbar {
    // Contexto fica atrás de uma única ação real. O modo, o esforço e o
    // workspace continuam disponíveis, sem disputar a atenção da escrita.
    @ViewBuilder var trailingControl: some View {
        trailingControlBranch
    }
}

extension ComposerToolbar {
    var trailingProcessing: some View {
        ZStack {
            BreathingDiamond(size: 13, reduceMotion: reduceMotion)
                .accessibilityHidden(true)
            Image(systemName: "arrow.up.circle.fill")
                .atlasSans(29)
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

extension ComposerToolbar {
    var trailingSendButton: some View {
        Button(action: onSend) {
            Image(systemName: "arrow.up.circle.fill")
                .atlasSans(29)
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
