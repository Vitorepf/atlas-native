import SwiftUI
import PhotosUI
import AtlasCore

// Send action — peel de ConversationComposer+Actions.

extension ConversationComposer {
    func send() {
        AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
        let text = model.draftText
        let effort = model.effort
        Task { await model.send(text, effort: effort) }
    }
}
