import SwiftUI
import AtlasCore

// Connector — peel de AtlasCodeCommitRow+Spine.
// Node → AtlasCodeCommitRow+SpineNode.swift

extension AtlasCodeCommitRow {
    func spineConnector(fill: Color) -> some View {
        Rectangle()
            .fill(fill)
            .frame(width: 2)
            .accessibilityHidden(true)
    }
}
