import SwiftUI

// Optional a11y id — peel de AutonomosLoadedSection+Lines.

struct OptionalA11yIdentifier: ViewModifier {
    let identifier: String?

    func body(content: Content) -> some View {
        if let identifier {
            content.accessibilityIdentifier(identifier)
        } else {
            content
        }
    }
}
