import SwiftUI
import UIKit
import AtlasCore

// Empty/fail prefixes — peel de ConversationView+A11yScreen.

extension ConversationView {
    func spokenConversationEmptyPrefix() -> String? {
        if model.loadError != nil, model.bubbles.isEmpty {
            return "\(title), falha ao carregar"
        }
        if model.bubbles.isEmpty {
            return "\(title), conversa vazia"
        }
        return nil
    }
}
