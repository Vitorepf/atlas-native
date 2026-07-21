import SwiftUI
import AtlasCore

// Remove button a11y — peel de DraftThumb+Chrome.

extension DraftThumb {
    func removeButtonA11y<Content: View>(_ content: Content) -> some View {
        content
            .accessibilityLabel(DraftThumbA11y.spokenRemove(draft))
            .accessibilityHint(DraftThumbA11y.removeHint)
            .accessibilityIdentifier(A11yID.draftRemove(draft.id))
    }
}
