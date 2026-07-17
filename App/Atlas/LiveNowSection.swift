import SwiftUI
import AtlasCore

/// "VIVO AGORA" — a home vira cockpit quando há sessão observada neste
/// processo. Sem sessões a seção não existe (lei V1: estado por exceção).
/// Com 2+ sessões vira Session Hub na home (zero Route nova).
struct LiveNowSection: View {
    let localSessions: [LiveSessionSnapshot]
    let remoteSessions: [LiveSessionSnapshot]
    let onOpen: (ThreadID, String) -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var sessions: [LiveSessionSnapshot] {
        Self.merged(local: localSessions, remote: remoteSessions)
    }

    private var isHub: Bool { sessions.count >= 2 }
    private var remoteCount: Int { sessions.filter(\.isRemote).count }

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
                    reduceMotion: reduceMotion,
                    remoteBadgeID: session.isRemote ? A11yID.liveNowRemoteBadge(index) : nil
                ) {
                    guard let threadId = session.threadId else { return }
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
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
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: sessions.map(\.id))
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("VIVO AGORA")
                .font(AtlasFont.mono(11))
                .tracking(1.4)
                .foregroundStyle(AtlasTheme.textTertiary)
            if isHub {
                Text("× \(sessions.count)")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.accent)
                    .accessibilityLabel("\(sessions.count) sessões vivas")
                if remoteCount > 0 {
                    Text("· \(remoteCount) remota\(remoteCount == 1 ? "" : "s")")
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .accessibilityLabel("\(remoteCount) sessão\(remoteCount == 1 ? "" : "ões") remota\(remoteCount == 1 ? "" : "s") em outra superfície")
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.bottom, isHub ? 12 : 0)
    }

    static func merged(local: [LiveSessionSnapshot], remote: [LiveSessionSnapshot]) -> [LiveSessionSnapshot] {
        var seenThreads = Set(local.compactMap { $0.threadId?.rawValue })
        var seenRemoteIDs: Set<String> = []
        let filteredRemote = remote.filter { session in
            if let thread = session.threadId?.rawValue {
                guard !seenThreads.contains(thread) else { return false }
                seenThreads.insert(thread)
                return true
            }
            return seenRemoteIDs.insert(session.id).inserted
        }
        return local + filteredRemote
    }
}
