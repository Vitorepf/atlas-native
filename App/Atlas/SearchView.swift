import SwiftUI
import AtlasCore

// IDLE-COMPRESS host

// --- SearchView.swift ---
struct SearchView: View {
    @Environment(AtlasSession.self) var session
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var query = ""
    @FocusState var focused: Bool

    var body: some View {
        searchA11yChrome(searchBackgroundShell)
    }
}

