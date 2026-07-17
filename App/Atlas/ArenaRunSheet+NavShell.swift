import SwiftUI
import AtlasCore

// Nav shell — peel de ArenaRunSheet.

extension ArenaRunSheet {
    var runNavShell: some View {
        NavigationStack {
            runScrollBody
        }
    }
}
