import SwiftUI
import AtlasCore

/// Relógio RM-safe do widget Sessão viva — peel de LiveSessionWidgetView.
// Branch → AtlasWidgetAccessories+LiveSession+Timer+Branch.swift
// Style → AtlasWidgetAccessories+LiveSession+Timer+Style.swift

struct LiveSessionWidgetTimer: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let live: AtlasNativeSnapshot.LiveSession

    var body: some View {
        timerStyle(Group { timerBranchBody })
    }
}
