import SwiftUI
import AtlasCore

/// Linha de arquivo com aceite/rejeição por patch — peel de ChangeReviewDiffSection (C16).
struct ChangeReviewFileRow: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID
    let patch: AtlasTraceChangeReview.Patch
    let file: String

    private var decided: AtlasTraceChangeReview.FileReview? {
        patch.fileReviews.first { $0.filePath == file }
    }

    private var displayName: String { (file as NSString).lastPathComponent }

    private var fileKindCaption: String? {
        if patch.createdFiles.contains(file) { return "novo" }
        if patch.deletedFiles.contains(file) { return "removido" }
        return nil
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(displayName)
                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
            if let kind = fileKindCaption {
                Text(kind).font(AtlasFont.mono(9))
                    .foregroundStyle(kind == "novo" ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
            }
            Spacer()
            if let decided {
                Text(decided.action == .accept ? "aceito" : "rejeitado")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(decided.action == .accept ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
                    .accessibilityLabel(decidedSpoken(decided))
            } else {
                Button("aceitar") {
                    Task {
                        await reviews.applyChangeReviewFile(
                            traceId: traceId, patchId: patch.patchID,
                            filePath: file, action: .accept
                        )
                    }
                }
                .buttonStyle(PressableScale())
                .font(.system(.caption, weight: .medium)).foregroundStyle(AtlasTheme.accent)
                .accessibilityLabel("aceitar \(displayName)")
                .accessibilityHint("registra aceite deste arquivo no patch")
                .accessibilityIdentifier(A11yID.reviewFileAccept(patchId: patch.id, filePath: file))

                Button("rejeitar") {
                    Task {
                        await reviews.applyChangeReviewFile(
                            traceId: traceId, patchId: patch.patchID,
                            filePath: file, action: .reject
                        )
                    }
                }
                .buttonStyle(PressableScale())
                .font(.system(.caption)).foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityLabel("rejeitar \(displayName)")
                .accessibilityHint("registra rejeição deste arquivo no patch")
                .accessibilityIdentifier(A11yID.reviewFileReject(patchId: patch.id, filePath: file))
            }
        }
        .padding(.vertical, 3)
        .accessibilityElement(children: decided == nil ? .contain : .combine)
        .accessibilityIdentifier(A11yID.reviewFileRow(patchId: patch.id, filePath: file))
    }

    private func decidedSpoken(_ review: AtlasTraceChangeReview.FileReview) -> String {
        var parts = [displayName]
        if let kind = fileKindCaption { parts.append("arquivo \(kind)") }
        parts.append(review.action == .accept ? "aceito" : "rejeitado")
        return parts.joined(separator: ", ")
    }
}
