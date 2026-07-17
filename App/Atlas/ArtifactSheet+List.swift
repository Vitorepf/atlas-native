import SwiftUI
import UIKit
import AtlasCore

// Lista de artefatos — peel de ArtifactSheet+Content.
// Row → ArtifactSheet+ListRow.swift

extension ArtifactSheet {
    var artifactList: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                artifactListRow(index: index, item: item)
                if index < items.count - 1 {
                    Divider().overlay(AtlasTheme.separatorSoft)
                        .accessibilityHidden(true)
                }
            }
        }
        .padding(.horizontal, 12)
        .atlasCard()
        .accessibilityElement(children: .contain)
        .accessibilityLabel("lista de artefatos, \(items.count) itens")
    }
}
