import AtlasCore
import SwiftUI

// Cycle 041 fuse → AtlasApp.swift

// Ponto de entrada do app SwiftUI puro. Casca fina: cria a sessão (que segura o
// AtlasClient do AtlasCore) e injeta no ambiente. Zero lógica de negócio aqui.
@main
struct AtlasApp: App {
    @Environment(\.scenePhase) var scenePhase
    @State var session = AtlasSession()

    init() {
        // Curva Dynamic Type do sans lida UMA vez na main — body nunca toca UIKit.
        AtlasSansScale.prime()
    }

    var body: some Scene {
        WindowGroup {
            atlasSceneLifecycle(
                RootView()
                    .environment(session)
            )
        }
    }
}
