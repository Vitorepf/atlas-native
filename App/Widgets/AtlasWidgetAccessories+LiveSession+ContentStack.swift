import WidgetKit
import SwiftUI
import AtlasCore

// Content stack — peel de AtlasWidgetAccessories+LiveSession+Content.
// Header → AtlasWidgetAccessories+LiveSession+ContentStack+Header.swift
// Branch → AtlasWidgetAccessories+LiveSession+ContentStack+Branch.swift

extension LiveSessionWidgetView {
    @ViewBuilder
    func liveSessionContentStack(snapshot: AtlasNativeSnapshot, live: AtlasNativeSnapshot.LiveSession?, stale: Bool) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            liveSessionContentHeaderRow(snapshot: snapshot, stale: stale)
            liveSessionContentBranchRow(snapshot: snapshot, live: live)
        }
    }
}
