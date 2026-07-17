import SwiftUI
import AtlasCore

// Artifacts button label — peel de ExecutionProof+Expanded+Artifacts.
// Chevron → ExecutionProof+Expanded+ArtifactsChevron.swift
// Lead → ExecutionProof+Expanded+ArtifactsLead.swift

extension ExecutionProof {
    func artifactsButtonLabel(count: Int) -> some View {
        HStack(spacing: 6) {
            artifactsButtonLead(count: count)
            artifactsChevron
        }
        .contentShape(Rectangle())
    }
}
