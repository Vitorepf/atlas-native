import SwiftUI

// Section caption a11y modifier — peel de AutonomosChrome+Caption.

struct SectionCaptionA11y: ViewModifier {
    let role: AutonomosChrome.SectionCaptionRole

    func body(content: Content) -> some View {
        switch role {
        case .decorative:
            content.accessibilityHidden(true)
        case .header:
            content.accessibilityAddTraits(.isHeader)
        }
    }
}
