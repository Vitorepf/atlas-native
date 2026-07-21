import SwiftUI
import PhotosUI
import AtlasCore

// Send / dismiss — WAVE-006.

extension ConversationComposer {
    func send() {
        AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
        let text = model.draftText
        let effort = model.effort
        Task { await model.send(text, effort: effort) }
    }

    func dismissKeyboard() {
        AtlasMotion.softImpact(reduceMotion: reduceMotion)
        if reduceMotion {
            focused.wrappedValue = false
        } else {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.86)) { focused.wrappedValue = false }
        }
    }
}
