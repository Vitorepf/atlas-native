import SwiftUI
import AtlasCore

// MARK: - ChangeReview chrome (peel de ChangeReviewSections)
// Toast → ChangeReviewSections+Toast.swift

struct ChangeReviewCaption: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text).font(AtlasFont.mono(10)).tracking(1.0).foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel(ChangeReviewSectionsA11y.spokenCaption(text))
    }
}
