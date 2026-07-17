import SwiftUI
import AtlasCore

/// Artefatos — peel de ExecutionProof+Expanded+Blocks.
/// Label → ExecutionProof+Expanded+ArtifactsLabel.swift

extension ExecutionProof {
    @ViewBuilder
    var artifactsBlock: some View {
        if !artifactItems.isEmpty, let traceId = bubble.traceId {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onOpenArtifacts(traceId)
            } label: {
                artifactsButtonLabel(count: artifactItems.count)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier(A11yID.artifactsRow)
            .accessibilityLabel("artefatos desta execução, \(artifactItems.count)")
            .accessibilityHint("abre a lista de artefatos deste trace")
        }
    }
}
