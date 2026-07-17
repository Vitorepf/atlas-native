import SwiftUI
import AtlasCore

// MARK: - ChangeReview chrome (peel de ChangeReviewSections)

struct ChangeReviewCaption: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text).font(AtlasFont.mono(10)).tracking(1.0).foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityAddTraits(.isHeader)
            .accessibilityLabel(ChangeReviewSectionsA11y.spokenCaption(text))
    }
}

struct ChangeReviewToast: View {
    let reviews: ChangeReviewModel
    var reduceMotion: Bool = false

    var body: some View {
        if let t = reviews.toast {
            Text(t)
                .font(AtlasFont.serifItalic(14)).foregroundStyle(AtlasTheme.textPrimary)
                .padding(.horizontal, 16).padding(.vertical, 9)
                .background(Capsule().fill(AtlasTheme.surfaceHi).overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
                .padding(.top, 8)
                .accessibilityLabel(ChangeReviewSectionsA11y.spokenToast(t))
                .accessibilityIdentifier(A11yID.reviewToast)
                .transition(reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity))
                .task {
                    try? await Task.sleep(nanoseconds: 1_400_000_000)
                    if reduceMotion { reviews.toast = nil }
                    else { withAnimation(AtlasMotion.editorial) { reviews.toast = nil } }
                }
        }
    }
}
