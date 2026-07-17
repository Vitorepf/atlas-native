import SwiftUI
import UIKit
import AtlasCore

// Artifact list row label — peel de ArtifactSheet+ListRow.
// Meta → ArtifactSheet+ListRowMeta.swift
// Leading → ArtifactSheet+ListRowLabel+Leading.swift

extension ArtifactSheet {
    func artifactListRowLabel(item: AtlasTraceArtifacts.Item) -> some View {
        HStack(spacing: 10) {
            artifactListRowLeading(item: item)
            Spacer()
            artifactListRowMeta(item: item)
        }
        .padding(.vertical, 10)
        .contentShape(Rectangle())
    }
}
