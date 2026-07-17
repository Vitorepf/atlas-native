import AtlasCore
import SwiftUI

/// Conteúdo carregado do radar — peel de `AtlasCodeRadarSections`.
/// Sections → AtlasCodeRadarLoadedContent+Sections.swift
struct AtlasCodeRadarLoadedContent: View {
    let workspace: AtlasCodeWorkspaceResponse
    let model: AtlasCodeWorkspaceModel
    let onOpenRepo: (String) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                radarSections
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 12)
            .padding(.bottom, 28)
        }
    }
}
