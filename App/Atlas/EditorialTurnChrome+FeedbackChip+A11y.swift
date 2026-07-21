import SwiftUI

// Feedback chip a11y — peel de EditorialTurnChrome+FeedbackChip.

extension FeedbackRow {
    func feedbackChipA11y<Content: View>(
        _ content: Content,
        kind: FeedbackKind,
        isActive: Bool
    ) -> some View {
        content
            .accessibilityLabel(EditorialTurnA11y.spokenFeedbackLabel(kind: kind, active: isActive))
            .accessibilityHint(EditorialTurnA11y.spokenFeedbackHint())
            .accessibilityAddTraits(isActive ? .isSelected : [])
            .accessibilityIdentifier(A11yID.editorialTurnFeedback(kind.rawValue))
    }
}
