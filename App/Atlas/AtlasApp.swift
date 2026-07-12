import SwiftUI

// Ponto de entrada do app SwiftUI puro. Casca fina: cria a sessão (que segura o
// AtlasClient do AtlasCore) e injeta no ambiente. Zero lógica de negócio aqui.
@main
struct AtlasApp: App {
    @State private var session = AtlasSession()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(session)
        }
    }
}
