import SwiftUI
import UIKit
import AtlasCore

// Lista de artefatos — peel de ArtifactSheet+Content.

extension ArtifactSheet {
    var artifactList: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                Button {
                    if !reduceMotion { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
                    selectedID = item.id
                } label: {
                    HStack(spacing: 10) {
                        Text("▸")
                            .font(AtlasFont.mono(11))
                            .foregroundStyle(item.id == selected?.id ? AtlasTheme.accent : AtlasTheme.textTertiary)
                            .accessibilityHidden(true)
                        Text(item.name)
                            .font(AtlasFont.serif(15, .semibold))
                            .foregroundStyle(AtlasTheme.textPrimary)
                            .lineLimit(1)
                            .accessibilityHidden(true)
                        Spacer()
                        Text("\(ArtifactViewer.byteLabel(item.byteSize))  \(ArtifactViewer.kindLabel(item.kind))")
                            .font(AtlasFont.mono(10))
                            .foregroundStyle(AtlasTheme.textTertiary)
                            .accessibilityHidden(true)
                    }
                    .padding(.vertical, 10)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(A11yID.artifactsItem(index))
                .accessibilityLabel("\(item.name), \(ArtifactViewer.byteLabel(item.byteSize)), \(ArtifactViewer.kindLabel(item.kind))")
                .accessibilityAddTraits(item.id == selected?.id ? .isSelected : [])
                .accessibilityHint(item.id == selected?.id ? "selecionado no preview" : "abre o preview deste artefato")
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
