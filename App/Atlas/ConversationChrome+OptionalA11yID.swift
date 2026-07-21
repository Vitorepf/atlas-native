import SwiftUI

// Optional a11y id — peel de ConversationChrome+SheetRow.

struct OptionalAccessibilityIdentifier: ViewModifier {
    let id: String?
    func body(content: Content) -> some View {
        if let id { content.accessibilityIdentifier(id) } else { content }
    }
}
