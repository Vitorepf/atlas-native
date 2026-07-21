import AtlasCore
import SwiftUI

// Cycle 044 fuse → AtlasApp.swift

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

extension AtlasApp {
    func atlasSceneBootstrap<Content: View>(_ content: Content) -> some View {
        content.task {
            NightlyProposalController.shared.installAsNotificationDelegate()
            LiveActivityRemoteBridge.shared.bootstrap(
                client: session.client,
                installationId: AtlasInstallationIdentity.id
            )
            session.setLiveSessionsPollingActive(scenePhase == .active)
        }
    }
}

extension AtlasApp {
    func atlasScenePhaseLifecycle<Content: View>(_ content: Content) -> some View {
        content.onChange(of: scenePhase) { _, phase in
            session.setLiveSessionsPollingActive(phase == .active)
            if phase == .background {
                Task {
                    await AtlasNativeSnapshotWriter.shared.write()
                    await NightlyProposalController.shared.scheduleForBackground()
                }
            }
        }
    }
}

extension AtlasApp {
    func atlasSceneLifecycle<Content: View>(_ content: Content) -> some View {
        atlasScenePhaseLifecycle(atlasSceneBootstrap(content))
    }
}
