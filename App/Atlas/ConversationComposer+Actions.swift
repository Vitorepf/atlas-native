import SwiftUI
import PhotosUI
import AtlasCore

// Ações do composer — peel de ConversationComposer (régua anti-inchaço).
// Steer → +Steer · Surface → +Surface.swift
// Queue → ConversationComposer+QueueLabels.swift

extension ConversationComposer {
    func dismissKeyboard() {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        if reduceMotion {
            focused.wrappedValue = false
        } else {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.86)) { focused.wrappedValue = false }
        }
    }

    func send() {
        AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
        let text = model.draftText
        let effort = model.effort
        Task { await model.send(text, effort: effort) }
    }
}
