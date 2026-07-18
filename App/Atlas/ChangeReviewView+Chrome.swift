import SwiftUI
import AtlasCore

// ChangeReview sheet chrome — peel de ChangeReviewView.

extension ChangeReviewSheet {
    var reviewSheetChrome: some View {
        NavigationStack {
            // Fundo como .background: destrava o scroll-edge material da barra.
            content
                .background(AtlasTheme.bg.ignoresSafeArea())
            .navigationTitle("Revisar mudanças")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { reviewToolbar }
            .overlay(alignment: .top) { ChangeReviewToast(reviews: reviews, reduceMotion: reduceMotion) }
            .accessibilityIdentifier(A11yID.reviewSheet)
            .accessibilityLabel(spokenReviewSheetLabel())
            .accessibilityHint(Self.reviewSheetHint)
        }
    }
}
