import AtlasCore
import SwiftUI

// IDLE-COMPRESS peel from ChangeReviewSections (canon §7.2 · same domain)

extension ChangeReviewPatchCard {
    @ViewBuilder
    var patchCardBody: some View {
        VStack(alignment: .leading, spacing: 10) {
            patchHeader
            ForEach(patch.changedFiles + patch.createdFiles + patch.deletedFiles, id: \.self) { file in
                ChangeReviewFileRow(reviews: reviews, traceId: traceId, patch: patch, file: file)
            }
            patchRiskFlags
            if diffExpanded {
                ChangeReviewDiffView(reviews: reviews, traceId: traceId, patch: patch)
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

extension ChangeReviewPatchCard {
    var diffExpanded: Bool { expandedDiffPatch == patch.id }
}

extension ChangeReviewPatchCard {
    var patchHeader: some View {
        HStack {
            Text("PATCH \(String(patch.id.prefix(8)))")
                .font(AtlasFont.mono(10)).tracking(0.8).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Spacer()
            Button(diffExpanded ? "Fechar diff" : "Ver diff") { toggleDiff() }
                .font(AtlasFont.mono(11, .medium)).foregroundStyle(AtlasTheme.accent)
                .accessibilityLabel(ChangeReviewJudgment.spokenDiffToggle(expanded: diffExpanded))
                .accessibilityHint("mostra ou oculta o conteúdo do diff para este patch")
                .accessibilityIdentifier(A11yID.reviewPatchDiff(patch.id))
        }
    }
}

extension ChangeReviewPatchCard {
    var patchRiskFlags: some View {
        Group {
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
                .accessibilityLabel(ChangeReviewJudgment.spokenRiskFlagsLabel(patch.riskFlags))
            }
        }
    }
}

extension ChangeReviewPatchCard {
    func toggleDiff() {
        if diffExpanded {
            expandedDiffPatch = nil
        } else {
            expandedDiffPatch = patch.id
            Task { await reviews.refreshChangeReviewDiff(traceId: traceId, patchId: patch.patchID) }
        }
    }
}

// MARK: - Patch / Diff (C15 · C16)
// DiffView → ChangeReviewDiffView.swift · Toggle → +Toggle · Header → +Header
// Chrome → ChangeReviewDiffSection+Chrome.swift
// Body → ChangeReviewDiffSection+Body.swift
// Expanded → ChangeReviewDiffSection+Expanded.swift
// Shell → ChangeReviewDiffSection+Shell.swift

struct ChangeReviewPatchCard: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID
    let patch: AtlasTraceChangeReview.Patch
    @Binding var expandedDiffPatch: String?
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        patchCardShell
    }
}

