import SwiftUI
import AtlasCore

// WAVE-013 fused ChangeReviewView.swift

extension ChangeReviewGovernanceSection {
    func governanceChrome<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AtlasTheme.surface.opacity(0.45), in: RoundedRectangle(cornerRadius: AtlasTheme.Radius.control))
            .accessibilityIdentifier(A11yID.reviewGovernance)
    }
}

extension ChangeReviewPatchCard {
    func patchCardChrome<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(14)
            .atlasCard()
            .accessibilityElement(children: .contain)
            .accessibilityLabel(ChangeReviewPatchA11y.spokenCard(patch: patch, diffExpanded: diffExpanded))
            .accessibilityIdentifier(A11yID.reviewPatchCard(patch.id))
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: diffExpanded)
    }
}

extension ChangeReviewPatchCard {
    var patchCardShell: some View {
        patchCardChrome { patchCardBody }
    }
}

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

extension ChangeReviewRunHeader {
    func runHeaderChrome<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(14)
            .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.card).fill(AtlasTheme.surface))
            .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.card).stroke(AtlasTheme.goldBorder, lineWidth: 1))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(ChangeReviewSectionsA11y.spokenRunHeader(run: run))
            .accessibilityIdentifier(A11yID.reviewRunHeader)
    }
}

struct ChangeReviewToast: View {
    let reviews: ChangeReviewModel
    var reduceMotion: Bool = false

    var body: some View {
        if let t = reviews.toast {
            toastCapsule(t)
                .accessibilityLabel(ChangeReviewSectionsA11y.spokenToast(t))
                .accessibilityIdentifier(A11yID.reviewToast)
                .transition(reduceMotion ? .opacity : .move(edge: .top).combined(with: .opacity))
                .task { await dismissToastAfterDelay() }
        }
    }
}

extension ChangeReviewToast {
    func dismissToastAfterDelay() async {
        try? await Task.sleep(nanoseconds: 1_400_000_000)
        if reduceMotion { reviews.toast = nil }
        else { withAnimation(AtlasMotion.editorial) { reviews.toast = nil } }
    }
}

extension ChangeReviewToast {
    func toastCapsule(_ text: String) -> some View {
        Text(text)
            .font(AtlasFont.serifItalic(14)).foregroundStyle(AtlasTheme.textPrimary)
            .padding(.horizontal, 16).padding(.vertical, 9)
            .background(Capsule().fill(AtlasTheme.surfaceHi).overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1)))
            .padding(.top, 8)
    }
}

extension ChangeReviewSheet {
    @ViewBuilder
    func reviewAvailableContent(_ review: AtlasTraceChangeReview) -> some View {
        switch review.state {
        case .unavailable:
            reviewUnavailableContent(review)
        case .available:
            reviewAvailableBranch(review)
        }
    }
}

extension ChangeReviewSheet {
    @ViewBuilder
    func reviewAvailableBranch(_ review: AtlasTraceChangeReview) -> some View {
        if Self.hasReviewSurface(review) {
            ChangeReviewAvailableContent(
                reviews: reviews,
                traceId: traceId,
                review: review,
                expandedDiffPatch: $expandedDiffPatch,
                applying: $applying
            )
        } else {
            reviewEmptySurface()
        }
    }
}

struct ChangeReviewAvailableContent: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID
    let review: AtlasTraceChangeReview
    @Binding var expandedDiffPatch: String?
    @Binding var applying: Bool

    var body: some View {
        reviewSections
    }
}

extension ChangeReviewSheet {
    func reviewUnavailableContent(_ review: AtlasTraceChangeReview) -> some View {
        TraceEvidenceUnavailable(
            title: "Sem revisão de mudanças nesta execução.",
            subtitle: TraceEvidenceCopy.unavailableReason(review.reason),
            identifier: A11yID.reviewUnavailable,
            spoken: TraceEvidenceCopy.unavailableSpoken(
                prefix: "sem revisão de mudanças nesta execução",
                reason: review.reason
            ),
            systemImage: "doc.text.magnifyingglass"
        )
    }
}

extension ChangeReviewSheet {
    func reviewEmptySurface() -> some View {
        TraceEvidenceUnavailable(
            title: "Revisão ligada, mas sem patches nem provas publicadas.",
            subtitle: "o servidor confirmou o vínculo, porém não há diff, checks ou achados a mostrar.",
            identifier: A11yID.reviewEmpty,
            spoken: "revisão ligada mas sem patches nem provas publicadas",
            systemImage: "doc.text.magnifyingglass"
        )
    }
}

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
            .accessibilityValue(reviewSheetFace.productWord)
            .accessibilityHint(Self.reviewSheetHint)
        }
    }
}

struct ChangeReviewSheet: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var expandedDiffPatch: String?
    @State var applying = false
    @State var loadFinished = false

    var review: AtlasTraceChangeReview? { reviews.changeReviewsByTrace[traceId] }

    var body: some View {
        reviewSheetChrome
            .task { await refreshReviewTask() }
    }
}

