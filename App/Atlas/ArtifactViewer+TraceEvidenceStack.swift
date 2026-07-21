import SwiftUI

// Unavailable stack — peel de ArtifactViewer+TraceEvidenceUnavailable.
// IconTitle → ArtifactViewer+TraceEvidenceStack+IconTitle.swift
// Subtitle → ArtifactViewer+TraceEvidenceStack+Subtitle.swift

extension TraceEvidenceUnavailable {
    var unavailableStack: some View {
        VStack(spacing: 12) {
            unavailableIconTitle
            unavailableSubtitle
        }
    }
}
