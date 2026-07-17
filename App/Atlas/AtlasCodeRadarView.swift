import AtlasCore
import SwiftUI

/// M3 · Código — o workspace do operador como ele realmente é.
/// Seções / linhas → AtlasCodeRadarSections.swift; model → AtlasCodeWorkspaceModel.swift.
/// Content → AtlasCodeRadarView+Content.swift
struct AtlasCodeRadarView: View {
    @Environment(AtlasSession.self) var session
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var model: AtlasCodeWorkspaceModel
    let onOpenRepo: (String) -> Void

    init(client: AtlasClient, onOpenRepo: @escaping (String) -> Void) {
        _model = State(initialValue: AtlasCodeWorkspaceModel(client: client))
        self.onOpenRepo = onOpenRepo
    }

    var body: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            radarNavShell(
                radarContent
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .bottom)))
                    .animation(reduceMotion ? nil : AtlasMotion.editorial, value: contentPhaseID)
            )
        }
    }
}
