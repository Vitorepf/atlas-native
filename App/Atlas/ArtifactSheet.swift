import SwiftUI
import UIKit
import AtlasCore

// Preview/zoom → ArtifactViewer.swift · conteúdo → ArtifactSheet+Content.swift · toast → +Toast
// Selection → ArtifactSheet+Selection.swift · Chrome → ArtifactSheet+Chrome.swift
// Lifecycle → ArtifactSheet+Lifecycle.swift
struct ArtifactSheet: View {
    let reviews: ChangeReviewModel
    let traceId: TraceID

    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var selectedID: String?
    @State var preview: ArtifactPreviewState = .idle
    @State var loadFinished = false
    @State var mountRevealed = 0

    var body: some View {
        artifactSheetLifecycle(artifactNavigationShell)
    }
}
