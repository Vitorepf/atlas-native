import SwiftUI
import AtlasCore

/// Aceitar por arquivo — peel de ChangeReviewFileRow (régua ≤100).
/// Reject → ChangeReviewFileRow+Reject.swift

extension ChangeReviewFileRow {
    var acceptButton: some View {
        Button("aceitar") {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
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
    }
}
