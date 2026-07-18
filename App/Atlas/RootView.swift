import SwiftUI
import AtlasCore

// Home Workspaces-primeiro (estilo Cursor, tema Atlas): masthead Fraunces, lista
// de repos reais (campo `workspace` das threads) + "Todas" + "Adicionar". Entrar
// num workspace abre suas conversas com filtro de área.
// Destinations → RootView+Destinations.swift · Nightly → RootView+Nightly.swift
// Lifecycle → RootView+Lifecycle.swift · Home → RootView+HomeStack.swift
struct RootView: View {
    @Environment(AtlasSession.self) var session
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var path = NavigationPath()
    @State var codeHub: AtlasCodeHubModel?
    @State var nightly = NightlyProposalController.shared

    var body: some View {
        rootLifecycleChrome(
            NavigationStack(path: $path) {
                rootHomeStack
            }
        )
    }
}
