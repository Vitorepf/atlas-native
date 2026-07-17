import SwiftUI
import AtlasCore

// MARK: - Patch / Diff (C15 · C16)
// Extraído de ChangeReviewSections sem mudança de comportamento.
// DiffView → ChangeReviewDiffView.swift.

struct ChangeReviewPatchCard: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID
    let patch: AtlasTraceChangeReview.Patch
    @Binding var expandedDiffPatch: String?
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var diffExpanded: Bool { expandedDiffPatch == patch.id }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("PATCH \(String(patch.id.prefix(8)))")
                    .font(AtlasFont.mono(10)).tracking(0.8).foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                Spacer()
                Button(diffExpanded ? "Fechar diff" : "Ver diff") { toggleDiff() }
                    .font(.system(.footnote, weight: .medium)).foregroundStyle(AtlasTheme.accent)
                    .accessibilityLabel(ChangeReviewPatchA11y.spokenDiffToggle(expanded: diffExpanded))
                    .accessibilityHint("mostra ou oculta o conteúdo do diff para este patch")
                    .accessibilityIdentifier(A11yID.reviewPatchDiff(patch.id))
            }
            ForEach(patch.changedFiles + patch.createdFiles + patch.deletedFiles, id: \.self) { file in
                ChangeReviewFileRow(reviews: reviews, traceId: traceId, patch: patch, file: file)
            }
            if !patch.riskFlags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(patch.riskFlags, id: \.self) { flag in
                        Text(flag).font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.domOperacional)
                            .padding(.horizontal, 7).padding(.vertical, 3)
                            .background(Capsule().stroke(AtlasTheme.domOperacional.opacity(0.4), lineWidth: 1))
                            .accessibilityHidden(true)
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(ChangeReviewPatchA11y.spokenRiskFlags(patch.riskFlags))
            }
            if diffExpanded {
                ChangeReviewDiffView(reviews: reviews, traceId: traceId, patch: patch)
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(14)
        .atlasCard()
        .accessibilityElement(children: .contain)
        .accessibilityLabel(ChangeReviewPatchA11y.spokenCard(patch: patch, diffExpanded: diffExpanded))
        .accessibilityIdentifier(A11yID.reviewPatchCard(patch.id))
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: diffExpanded)
    }

    private func toggleDiff() {
        if diffExpanded {
            expandedDiffPatch = nil
        } else {
            expandedDiffPatch = patch.id
            Task { await reviews.refreshChangeReviewDiff(traceId: traceId, patchId: patch.patchID) }
        }
    }
}
