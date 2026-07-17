import SwiftUI
import AtlasCore

/// "VIVO AGORA" — a home vira cockpit quando há sessão observada neste
/// processo. Sem sessões a seção não existe (lei V1: estado por exceção).
/// Com 2+ sessões vira Session Hub na home (zero Route nova).
/// Merge → +Merge · spoken → +A11y · Header → +Header
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
        VStack(alignment: .leading, spacing: isHub ? 0 : 12) {
            header
            ForEach(Array(sessions.enumerated()), id: \.element.id) { index, session in
                if isHub, index > 0 {
                    Rectangle()
                        .fill(AtlasTheme.separator.opacity(0.55))
                        .frame(height: 1)
                        .padding(.vertical, 10)
                        .accessibilityHidden(true)
                }
                LiveNowRow(
                    session: session,
                    hubMode: isHub,
                    hubIndex: isHub ? index : nil,
                    hubCount: isHub ? sessions.count : nil,
                    reduceMotion: reduceMotion,
                    remoteBadgeID: session.isRemote ? A11yID.liveNowRemoteBadge(index) : nil
                ) {
                    guard let threadId = session.threadId else { return }
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    onOpen(threadId, session.title)
                }
                .accessibilityIdentifier(A11yID.liveNowRow(index))
                .transition(reduceMotion ? .opacity : .asymmetric(
                    insertion: .opacity.combined(with: .offset(y: 8)),
                    removal: .opacity
                ))
            }
        }
        .padding(14)
        .atlasCard()
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.bottom, 18)
        .accessibilityIdentifier(A11yID.liveNowSection)
        .accessibilityLabel(Self.spokenSectionLabel(
            isHub: isHub, count: sessions.count, remoteCount: remoteCount
        ))
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: sessions.map(\.id))
    }
}
