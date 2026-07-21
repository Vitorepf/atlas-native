import AtlasCore
import SwiftUI

// Cycle 023 fuse → RootView+Home.swift

// Véu editorial (teal + gold) sob a lista; silêncio, não dashboard.

extension RootView {
    var homeAtmosphere: some View {
        ZStack {
            AtlasTheme.bg
            RadialGradient(
                colors: [AtlasTheme.accent.opacity(0.045), .clear],
                center: .top,
                startRadius: 20,
                endRadius: 320
            )
            RadialGradient(
                colors: [AtlasTheme.prussian.opacity(0.055), .clear],
                center: UnitPoint(x: 1.05, y: 0.82),
                startRadius: 10,
                endRadius: 280
            )
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

extension RootView {
    // A11y no CONTAINER carimbava identifier/label em todos os filhos (composer
    // virava "Atlas, início"; linhas de OPERAÇÃO ficavam mudas no VoiceOver).
    // Tela não fala por cima dos elementos: cada um carrega a própria voz.
    func rootHomeNavChrome<Content: View>(_ content: Content) -> some View {
        content
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: Route.self) { rootDestination(for: $0) }
    }
}

extension RootView {
    var rootHomeStack: some View {
        rootHomeNavChrome(
            ZStack(alignment: .bottom) {
                homeAtmosphere
                rootHomeSectionsStack
                inputBar
            }
        )
    }
}

extension RootView {
    @ViewBuilder
    var rootHomeSectionsStack: some View {
        VStack(alignment: .leading, spacing: 0) {
            topBar
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 4)
                .padding(.bottom, 14)

            RootHomeSections(
                reduceMotion: reduceMotion,
                onNavigate: { path.append($0) },
                onOpenThread: { id, title in path.append(Route.thread(id: id, title: title)) }
            )
        }
    }
}
