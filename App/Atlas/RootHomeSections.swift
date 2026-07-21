import SwiftUI
import AtlasCore

// IDLE-COMPRESS host

struct RootHomeSections: View {
    @Environment(AtlasSession.self) var session
    var reduceMotion: Bool
    var onNavigate: (Route) -> Void
    @State var showingWorkspacePicker = false
    var onOpenThread: (ThreadID, String) -> Void

    var body: some View {
        phaseBody
            // WAVE-047: light ops hydrate — fleet/taskHealth/areas; silence on fail.
            .task {
                await session.autonomos.refreshGlobalOpsForHome()
            }
    }
}

