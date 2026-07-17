import SwiftUI
import AtlasCore

// Loaded diff — peel de ChangeReviewDiffView+Body.
// Warnings → ChangeReviewDiffView+LoadedWarnings.swift

extension ChangeReviewDiffView {
    @ViewBuilder
    func loadedDiff(_ response: AtlasTraceChangeReviewDiffResponse) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            ScrollView(.horizontal, showsIndicators: false) {
                Text(response.diff.content)
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .textSelection(.enabled)
                    .padding(10)
            }
            .frame(maxHeight: 320)
            .background(RoundedRectangle(cornerRadius: 10).fill(AtlasTheme.bgRecessed))
            loadedDiffWarnings(response)
        }
        .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
    }
}
