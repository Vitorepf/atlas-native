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

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("PATCH \(String(patch.id.prefix(8)))")
                    .font(AtlasFont.mono(10)).tracking(0.8).foregroundStyle(AtlasTheme.textTertiary)
                Spacer()
                Button(expandedDiffPatch == patch.id ? "Fechar diff" : "Ver diff") {
                    if expandedDiffPatch == patch.id {
                        expandedDiffPatch = nil
                    } else {
                        expandedDiffPatch = patch.id
                        Task { await reviews.refreshChangeReviewDiff(traceId: traceId, patchId: patch.patchID) }
                    }
                }
                .font(.system(.footnote, weight: .medium)).foregroundStyle(AtlasTheme.accent)
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
                    }
                }
            }
            if expandedDiffPatch == patch.id {
                ChangeReviewDiffView(reviews: reviews, traceId: traceId, patch: patch)
            }
        }
        .padding(14)
        .atlasCard()
    }
}

struct ChangeReviewFileRow: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID
    let patch: AtlasTraceChangeReview.Patch
    let file: String

    private var decided: AtlasTraceChangeReview.FileReview? {
        patch.fileReviews.first { $0.filePath == file }
    }

    var body: some View {
        HStack(spacing: 8) {
            Text((file as NSString).lastPathComponent)
                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
            if patch.createdFiles.contains(file) {
                Text("novo").font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.domAutonomos)
            } else if patch.deletedFiles.contains(file) {
                Text("removido").font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.domOperacional)
            }
            Spacer()
            if let decided {
                Text(decided.action == .accept ? "aceito" : "rejeitado")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(decided.action == .accept ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
            } else {
                Button("aceitar") {
                    Task { await reviews.applyChangeReviewFile(traceId: traceId, patchId: patch.patchID,
                                                             filePath: file, action: .accept) }
                }
                .font(.system(.caption, weight: .medium)).foregroundStyle(AtlasTheme.accent)
                Button("rejeitar") {
                    Task { await reviews.applyChangeReviewFile(traceId: traceId, patchId: patch.patchID,
                                                             filePath: file, action: .reject) }
                }
                .font(.system(.caption)).foregroundStyle(AtlasTheme.textTertiary)
            }
        }
        .padding(.vertical, 3)
    }
}
