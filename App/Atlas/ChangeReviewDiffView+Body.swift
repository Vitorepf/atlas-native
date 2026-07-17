import SwiftUI
import AtlasCore

// Diff loaded/unavailable — peel de ChangeReviewDiffView.

extension ChangeReviewDiffView {
    @ViewBuilder
    func diffBody(response: AtlasTraceChangeReviewDiffResponse?) -> some View {
        if let response {
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
                if response.diff.truncated {
                    Text("diff truncado — \(response.diff.returnedBytes) de \(response.diff.sizeBytes) bytes")
                        .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
                }
                if response.patch.hashMatches == false {
                    ChangeReviewHashWarning()
                }
            }
            .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
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
