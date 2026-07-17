import SwiftUI

// Feedback chip button — peel de EditorialTurnChrome+Feedback.

extension FeedbackRow {
    func feedbackChip(_ kind: FeedbackKind) -> some View {
        let isActive = active == kind.activeAction
        return Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onFeedback(kind)
        } label: {
            Text(isActive ? "\(kind.label) ✓" : kind.label)
                .font(AtlasFont.serifItalic(13))
                .foregroundStyle(isActive ? AtlasTheme.domAutonomos : AtlasTheme.textTertiary)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .overlay(Capsule().stroke(isActive ? AtlasTheme.domAutonomos.opacity(0.5) : AtlasTheme.separator, lineWidth: 1))
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel(EditorialTurnA11y.spokenFeedbackLabel(kind: kind, active: isActive))
        .accessibilityHint(EditorialTurnA11y.spokenFeedbackHint())
        .accessibilityAddTraits(isActive ? .isSelected : [])
        .accessibilityIdentifier(A11yID.editorialTurnFeedback(kind.rawValue))
    }
}
