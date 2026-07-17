import SwiftUI
import AtlasCore

/// "VIVO AGORA" — a home vira cockpit quando há sessão observada neste
/// processo. Sem sessões a seção não existe (lei V1: estado por exceção).
/// Com 2+ sessões vira Session Hub na home (zero Route nova).
/// Merge → +Merge · spoken → +A11y · Header → +Header · Rows → +Rows
/// Chrome → LiveNowSection+Chrome.swift
struct LiveNowSection: View {
    let localSessions: [LiveSessionSnapshot]
    let remoteSessions: [LiveSessionSnapshot]
    let onOpen: (ThreadID, String) -> Void
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var sessions: [LiveSessionSnapshot] {
        Self.merged(local: localSessions, remote: remoteSessions)
    }

    var isHub: Bool { sessions.count >= 2 }
    var remoteCount: Int { sessions.filter(\.isRemote).count }

    var body: some View {
        liveNowChrome
    }
}
