import SwiftUI
import UIKit
import AtlasCore

// Preview/zoom → ArtifactViewer.swift · conteúdo → ArtifactSheet+Content.swift · toast → +Toast
// Selection → ArtifactSheet+Selection.swift · Chrome → ArtifactSheet+Chrome.swift
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
        NavigationStack {
            artifactSheetChrome(
                ZStack {
                    AtlasTheme.bg.ignoresSafeArea()
                    content
                }
            )
        }
        .task {
            await reviews.refreshChangeReview(traceId: traceId)
            loadFinished = true
            if hasDeliveryProof { await runMountAnimation() }
            else { mountRevealed = deliveryChecks.count }
        }
        .onChange(of: items.map(\.id)) { _, ids in
            if selectedID == nil || selectedID.map({ !ids.contains($0) }) == true {
                selectedID = ids.first
            }
        }
        .task(id: selected?.id) {
            guard mountComplete, let selected else { return }
            await load(selected)
        }
    }
}
