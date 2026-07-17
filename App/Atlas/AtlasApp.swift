import SwiftUI
import AtlasCore

// Ponto de entrada do app SwiftUI puro. Casca fina: cria a sessão (que segura o
// AtlasClient do AtlasCore) e injeta no ambiente. Zero lógica de negócio aqui.
@main
struct AtlasApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var session = AtlasSession()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(session)
                .task {
                    NightlyProposalController.shared.installAsNotificationDelegate()
                    LiveActivityRemoteBridge.shared.bootstrap(
                        client: session.client,
                        installationId: AtlasInstallationIdentity.id
                    )
                    session.setLiveSessionsPollingActive(scenePhase == .active)
                }
                .onChange(of: scenePhase) { _, phase in
                    session.setLiveSessionsPollingActive(phase == .active)
                    if phase == .background {
                        Task { await NightlyProposalController.shared.scheduleForBackground() }
                    }
                }
        }
    }
}
