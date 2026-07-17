import SwiftUI
import AtlasCore

struct ChangeReviewDiffView: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID
    let patch: AtlasTraceChangeReview.Patch
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var loadSettled = false

    var body: some View {
        Group {
            if let response = reviews.changeReviewDiff(traceId: traceId, patchId: patch.patchID) {
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
                        Text("atenção: o hash do diff não confere com o artefato registrado")
                            .font(.caption).foregroundStyle(AtlasTheme.domOperacional)
                    }
                }
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
        .task(id: patch.id) {
            loadSettled = false
            if reviews.changeReviewDiff(traceId: traceId, patchId: patch.patchID) == nil {
                await reviews.refreshChangeReviewDiff(traceId: traceId, patchId: patch.patchID)
            }
            loadSettled = true
        }
    }
}
