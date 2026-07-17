import SwiftUI
import AtlasCore

// Run header chrome — peel de ChangeReviewSections.

extension ChangeReviewRunHeader {
    func runHeaderChrome<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 14).fill(AtlasTheme.surface))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(AtlasTheme.goldBorder, lineWidth: 1))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(ChangeReviewSectionsA11y.spokenRunHeader(run: run))
            .accessibilityIdentifier(A11yID.reviewRunHeader)
    }
}
