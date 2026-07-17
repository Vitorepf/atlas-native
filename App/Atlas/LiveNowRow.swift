import SwiftUI
import AtlasCore

/// Uma linha do Session Hub / VIVO AGORA — title, phase, timing, elapsed.
/// Content → LiveNowRow+Content.swift
/// A11y → LiveNowRow+A11yShell.swift
struct LiveNowRow: View {
    let session: LiveSessionSnapshot
    let hubMode: Bool
    let hubIndex: Int?
    let hubCount: Int?
    let reduceMotion: Bool
    let remoteBadgeID: String?
    let onTap: () -> Void

    var navigable: Bool { session.threadId != nil }

    var body: some View {
        liveNowA11yShell
    }
}
