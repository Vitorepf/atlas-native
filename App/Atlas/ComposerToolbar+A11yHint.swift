import SwiftUI
import AtlasCore

// Send hint — peel de ComposerToolbar+A11y.
// Ready → ComposerToolbar+A11ySendHintReady.swift
// Blocked → ComposerToolbar+A11ySendHintBlocked.swift

extension ComposerToolbar {
    func spokenSendHint(canSubmit: Bool) -> String {
        canSubmit ? spokenSendHintReady() : spokenSendHintBlocked()
    }
}
