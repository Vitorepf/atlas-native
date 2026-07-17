import SwiftUI
import AtlasCore

// Diff loaded/unavailable — peel de ChangeReviewDiffView.
// Loaded → ChangeReviewDiffView+Loaded.swift

extension ChangeReviewDiffView {
    @ViewBuilder
    func diffBody(response: AtlasTraceChangeReviewDiffResponse?) -> some View {
        if let response {
            loadedDiff(response)
        } else if !loadSettled {
            TraceEvidenceLoading(text: "carregando diff…", reduceMotion: reduceMotion)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
        } else {
            Text("diff indisponível para este patch")
                .font(AtlasFont.serifItalic(13))
                .foregroundStyle(AtlasTheme.textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 8)
                .accessibilityLabel("diff indisponível para este patch")
                .accessibilityIdentifier(A11yID.reviewDiffUnavailable)
        }
    }
}
