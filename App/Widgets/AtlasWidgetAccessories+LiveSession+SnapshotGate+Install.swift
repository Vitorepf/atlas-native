import WidgetKit
import SwiftUI
import AtlasCore

// Install prompt branch — peel de AtlasWidgetAccessories+LiveSession+SnapshotGate.

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionInstallGate<Content: View>(
        snapshot: AtlasNativeSnapshot?,
        @ViewBuilder content: (AtlasNativeSnapshot) -> Content
    ) -> some View {
        if let snapshot {
            content(snapshot)
        } else {
            InstallPromptView()
        }
    }
}
