import SwiftUI
import AtlasCore

// MARK: - Patch / Diff (C15 · C16)
// Extraído de ChangeReviewSections sem mudança de comportamento.

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

/// Estado por arquivo vem SÓ de patch.fileReviews; decidir chama o model
/// e a linha muda apenas quando o recibo voltar na projeção canônica.
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
