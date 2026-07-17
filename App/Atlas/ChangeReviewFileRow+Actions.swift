import SwiftUI
import AtlasCore

/// Aceitar/rejeitar por arquivo — peel de ChangeReviewFileRow (régua ≤100).

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
        .font(.system(.caption)).foregroundStyle(AtlasTheme.textTertiary)
        .accessibilityLabel("rejeitar \(displayName)")
        .accessibilityHint("registra rejeição deste arquivo no patch")
        .accessibilityIdentifier(A11yID.reviewFileReject(patchId: patch.id, filePath: file))
    }
}
