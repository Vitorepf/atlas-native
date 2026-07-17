import WidgetKit
import SwiftUI
import AtlasCore

// Snapshot entry gate — peel de AtlasWidgetAccessories+CodeWeek.
// Published → AtlasWidgetAccessories+CodeWeek+EntryGate+Published.swift

extension CodeWeekWidgetView {
    @ViewBuilder
    func codeWeekEntryView(snapshot: AtlasNativeSnapshot?) -> some View {
        if let snapshot {
            codeWeekPublishedView(snapshot: snapshot)
        } else {
            InstallPromptView()
        }
    }
}
