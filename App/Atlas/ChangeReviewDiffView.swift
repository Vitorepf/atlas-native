import AtlasCore
import SwiftUI

// Cycle 044 fuse → ChangeReviewDiffView.swift

struct ChangeReviewDiffView: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID
    let patch: AtlasTraceChangeReview.Patch
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var loadSettled = false

    var body: some View {
        Group {
            diffBody(response: reviews.changeReviewDiff(traceId: traceId, patchId: patch.patchID))
        }
        .task(id: patch.id) {
            await diffLoadTask()
        }
    }
}

extension ChangeReviewDiffView {
    @ViewBuilder
    var diffBodyLoading: some View {
        TraceEvidenceLoading(text: "carregando diff…", reduceMotion: reduceMotion)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
    }
}

extension ChangeReviewDiffView {
    @ViewBuilder
    var diffBodyUnavailable: some View {
        Text("diff indisponível para este patch")
            .font(AtlasFont.serifItalic(13))
            .foregroundStyle(AtlasTheme.textTertiary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 8)
            .accessibilityLabel("diff indisponível para este patch")
            .accessibilityIdentifier(A11yID.reviewDiffUnavailable)
    }
}

extension ChangeReviewDiffView {
    @ViewBuilder
    func diffBody(response: AtlasTraceChangeReviewDiffResponse?) -> some View {
        if let response {
            loadedDiff(response)
        } else if !loadSettled {
            diffBodyLoading
        } else {
            diffBodyUnavailable
        }
    }
}

extension ChangeReviewDiffView {
    @ViewBuilder
    func loadedDiffScroll(_ response: AtlasTraceChangeReviewDiffResponse) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            Text(response.diff.content)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textSecondary)
                .textSelection(.enabled)
                .padding(10)
        }
        .frame(maxHeight: 320)
        .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).fill(AtlasTheme.bgRecessed))
    }
}

extension ChangeReviewDiffView {
    @ViewBuilder
    func loadedDiff(_ response: AtlasTraceChangeReviewDiffResponse) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            loadedDiffScroll(response)
            loadedDiffWarnings(response)
        }
        .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
    }
}

extension ChangeReviewDiffView {
    func diffLoadTask() async {
        loadSettled = false
        if reviews.changeReviewDiff(traceId: traceId, patchId: patch.patchID) == nil {
            await reviews.refreshChangeReviewDiff(traceId: traceId, patchId: patch.patchID)
        }
        loadSettled = true
    }
}

extension ChangeReviewDiffView {
    @ViewBuilder
    func loadedDiffWarnings(_ response: AtlasTraceChangeReviewDiffResponse) -> some View {
        if response.diff.truncated {
            Text("diff truncado — \(response.diff.returnedBytes) de \(response.diff.sizeBytes) bytes")
                .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
        }
        if response.patch.hashMatches == false {
            hashMismatchWarning
        }
    }

    var hashMismatchWarning: some View {
        HStack(alignment: .top, spacing: 6) {
            Image(systemName: "exclamationmark.triangle.fill")
                .atlasSans(11, .semibold)
                .foregroundStyle(AtlasTheme.domOperacional)
                .accessibilityHidden(true)
            Text("atenção: o hash do diff não confere com o artefato registrado")
                .font(.caption)
                .foregroundStyle(AtlasTheme.domOperacional)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("atenção: o hash do diff não confere com o artefato registrado")
        .accessibilityIdentifier(A11yID.reviewHashWarning)
    }
}
