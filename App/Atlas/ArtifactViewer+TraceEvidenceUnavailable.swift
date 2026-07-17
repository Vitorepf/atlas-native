import SwiftUI

/// Empty/unavailable compartilhado por ArtifactSheet e ChangeReviewSheet.
/// Peel de ArtifactViewer+TraceEvidence.
/// Stack → ArtifactViewer+TraceEvidenceStack.swift

struct TraceEvidenceUnavailable: View {
    let title: String
    let subtitle: String?
    let identifier: String
    let spoken: String
    var systemImage: String = "doc.text"

    var body: some View {
        unavailableStack
            .padding(36)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spoken)
            .accessibilityIdentifier(identifier)
    }
}
