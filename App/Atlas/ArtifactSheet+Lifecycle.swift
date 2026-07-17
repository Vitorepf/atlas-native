import SwiftUI
import UIKit
import AtlasCore

// Artifact sheet lifecycle — peel de ArtifactSheet.
// InitialTask → ArtifactSheet+Lifecycle+InitialTask.swift
// SelectionSync → ArtifactSheet+Lifecycle+SelectionSync.swift
// PreviewTask → ArtifactSheet+Lifecycle+PreviewTask.swift

extension ArtifactSheet {
    func artifactSheetLifecycle<Content: View>(_ content: Content) -> some View {
        content
            .task { await artifactSheetInitialTask() }
            .onChange(of: items.map(\.id)) { _, ids in artifactSheetSyncSelection(ids: ids) }
            .task(id: selected?.id) { await artifactSheetPreviewTask(for: selected) }
    }
}
