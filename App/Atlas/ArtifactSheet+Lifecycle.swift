import SwiftUI
import UIKit
import AtlasCore

// Artifact sheet lifecycle — peel de ArtifactSheet.

extension ArtifactSheet {
    func artifactSheetLifecycle<Content: View>(_ content: Content) -> some View {
        content
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
