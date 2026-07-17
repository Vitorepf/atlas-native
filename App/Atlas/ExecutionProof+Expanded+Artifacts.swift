import SwiftUI
import AtlasCore

/// Artefatos — peel de ExecutionProof+Expanded+Blocks.
/// Label → ExecutionProof+Expanded+ArtifactsLabel.swift
/// A11y → ExecutionProof+Expanded+ArtifactsA11y.swift

extension ExecutionProof {
    @ViewBuilder
    var artifactsBlock: some View {
        if !artifactItems.isEmpty, let traceId = bubble.traceId {
            artifactsButtonA11y(
                Button {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    onOpenArtifacts(traceId)
                } label: {
                    artifactsButtonLabel(count: artifactItems.count)
                },
                count: artifactItems.count
            )
        }
    }
}
