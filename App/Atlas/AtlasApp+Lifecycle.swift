import SwiftUI
import AtlasCore

// App scene lifecycle — peel de AtlasApp.

extension AtlasApp {
    func atlasSceneLifecycle<Content: View>(_ content: Content) -> some View {
        content
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
                    Task {
                        await AtlasNativeSnapshotWriter.shared.write()
                        await NightlyProposalController.shared.scheduleForBackground()
                    }
                }
            }
    }
}
