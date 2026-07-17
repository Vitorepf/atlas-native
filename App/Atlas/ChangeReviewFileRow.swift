import SwiftUI
import AtlasCore

/// Linha de arquivo com aceite/rejeição por patch — peel de ChangeReviewDiffSection (C16).
/// Ações: +Actions · a11y: +A11y.
struct ChangeReviewFileRow: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID
    let patch: AtlasTraceChangeReview.Patch
    let file: String
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var decided: AtlasTraceChangeReview.FileReview? {
        patch.fileReviews.first { $0.filePath == file }
    }

    var displayName: String { (file as NSString).lastPathComponent }

    var fileKindCaption: String? {
        if patch.createdFiles.contains(file) { return "novo" }
        if patch.deletedFiles.contains(file) { return "removido" }
        return nil
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(displayName)
                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
                .accessibilityHidden(true)
            if let kind = fileKindCaption {
                Text(kind).font(AtlasFont.mono(9))
                    .foregroundStyle(kind == "novo" ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
                    .accessibilityHidden(true)
            }
            Spacer()
            if let decided {
                Text(decided.action == .accept ? "aceito" : "rejeitado")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(decided.action == .accept ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
                    .accessibilityHidden(true)
            } else {
                acceptButton
                rejectButton
            }
        }
        .padding(.vertical, 3)
        .modifier(ChangeReviewFileRowA11y(
            decidedLabel: decided.map {
                ChangeReviewFileRowA11y.spoken(displayName: displayName, kind: fileKindCaption, review: $0)
            },
            identifier: A11yID.reviewFileRow(patchId: patch.id, filePath: file)
        ))
    }
}
