import SwiftUI
import AtlasCore

// Root home nav chrome — peel de RootView+HomeStack.

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
