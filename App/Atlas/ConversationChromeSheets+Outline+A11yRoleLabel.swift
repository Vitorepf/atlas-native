import Foundation

// Outline role label — peel de ConversationChromeSheets+Outline+A11yRole.

extension ConversationOutlineA11y {
    static func spokenRole(_ role: String) -> String {
        role == "user" ? "você" : "Atlas"
    }
}
