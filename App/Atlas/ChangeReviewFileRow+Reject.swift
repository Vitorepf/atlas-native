import SwiftUI
import AtlasCore

// Reject file — peel de ChangeReviewFileRow+Actions.

extension ChangeReviewFileRow {
    var rejectButton: some View {
        Button("rejeitar") {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            Task {
                await reviews.applyChangeReviewFile(
                    traceId: traceId, patchId: patch.patchID,
                    filePath: file, action: .reject
                )
            }
        }
        .buttonStyle(PressableScale())
        .font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textTertiary)
        .accessibilityLabel("rejeitar \(displayName)")
        .accessibilityHint("registra rejeição deste arquivo no patch")
        .accessibilityIdentifier(A11yID.reviewFileReject(patchId: patch.id, filePath: file))
    }
}
