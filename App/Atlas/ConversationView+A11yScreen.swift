import SwiftUI
import UIKit
import AtlasCore

/// Screen spoken — peel de ConversationView+A11y.

extension ConversationView {
    func spokenConversationScreenLabel() -> String {
        if model.loadError != nil, model.bubbles.isEmpty {
            return "\(title), falha ao carregar"
        }
        if model.bubbles.isEmpty {
            return "\(title), conversa vazia"
        }
        var parts = [title, "\(model.bubbles.count) turno\(model.bubbles.count == 1 ? "" : "s")"]
        if model.isSending { parts.append("enviando") }
        if model.showingStaleCache { parts.append("cache desatualizado") }
        return parts.joined(separator: ", ")
    }
}
