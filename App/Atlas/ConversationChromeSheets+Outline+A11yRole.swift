import Foundation
import AtlasCore

/// Outline role helpers — peel de ConversationChromeSheets+Outline+A11y.
/// Role → ConversationChromeSheets+Outline+A11yRoleLabel.swift
/// Row → ConversationChromeSheets+Outline+A11yRowLabel.swift

extension ConversationOutlineA11y {
    static func spokenSnippet(from text: String) -> String {
        ConversationOutlineA11ySnippet.spokenSnippet(from: text)
    }
}
