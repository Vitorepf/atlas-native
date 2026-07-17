import SwiftUI
import AtlasCore

// Spine column — peel de AtlasCodeCommitRow+Spine.
// Connectors → AtlasCodeCommitRow+Spine+Column+Connectors.swift
// Frame → AtlasCodeCommitRow+Spine+Column+Frame.swift

extension AtlasCodeCommitRow {
    @ViewBuilder
    func spineColumn(spineTint: Color, motion: Animation?) -> some View {
        spineColumnFrame(
            spineColumnConnectors(spineTint: spineTint, motion: motion),
            motion: motion
        )
    }
}
