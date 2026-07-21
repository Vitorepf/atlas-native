import AtlasCore
import SwiftUI

// IDLE-COMPRESS fused

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

@main
struct AtlasApp: App {
    @Environment(\.scenePhase) var scenePhase
    @State var session = AtlasSession()

    init() {
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
