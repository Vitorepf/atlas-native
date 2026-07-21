import SwiftUI
import AtlasCore

/// "VIVO AGORA" — home vira cockpit quando há sessão neste processo.
/// Sem sessões a seção não existe. Com 2+ = Session Hub (zero Route nova).
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
                rowCell(index: index, session: session)
            }
        }
        .padding(14)
        .atlasCard()
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.bottom, 18)
        .accessibilityIdentifier(A11yID.liveNowSection)
        // Contain without fused section label so each LiveNowRow stays focusable.
        .accessibilityElement(children: .contain)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: sessions.map(\.id))
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("VIVO AGORA")
                .font(AtlasFont.mono(11))
                .tracking(1.4)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel(Self.spokenSectionLabel(
                    isHub: isHub, count: sessions.count, remoteCount: remoteCount
                ))
            if isHub {
                Text("× \(sessions.count)")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.accent)
                    .accessibilityHidden(true)
                if remoteCount > 0 {
                    Text("· \(remoteCount) remota\(remoteCount == 1 ? "" : "s")")
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .accessibilityHidden(true)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.bottom, isHub ? 12 : 0)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Self.spokenSectionLabel(
            isHub: isHub, count: sessions.count, remoteCount: remoteCount
        ))
    }

    private func rowCell(index: Int, session: LiveSessionSnapshot) -> some View {
        LiveNowRow(
            session: session,
            hubMode: isHub,
            hubIndex: isHub ? index : nil,
            hubCount: isHub ? sessions.count : nil,
            reduceMotion: reduceMotion,
            remoteBadgeID: session.isRemote ? A11yID.liveNowRemoteBadge(index) : nil
        ) {
            // Soft haptic already fires in LiveNowRow — avoid double impact.
            guard let threadId = session.threadId else { return }
            onOpen(threadId, session.title)
        }
        .accessibilityIdentifier(A11yID.liveNowRow(index))
        .transition(reduceMotion ? .opacity : .asymmetric(
            insertion: .opacity.combined(with: .offset(y: 8)),
            removal: .opacity
        ))
    }

    static func spokenSectionLabel(isHub: Bool, count: Int, remoteCount: Int) -> String {
        guard isHub else { return "vivo agora" }
        var label = "vivo agora, \(count) sessões vivas"
        if remoteCount > 0 {
            label += ", \(remoteCount) remota\(remoteCount == 1 ? "" : "s") em outra superfície"
        }
        return label
    }

    static func merged(local: [LiveSessionSnapshot], remote: [LiveSessionSnapshot]) -> [LiveSessionSnapshot] {
        local + filteredRemote(local: local, remote: remote)
    }

    static func filteredRemote(
        local: [LiveSessionSnapshot],
        remote: [LiveSessionSnapshot]
    ) -> [LiveSessionSnapshot] {
        var seenThreads = Set(local.compactMap { $0.threadId?.rawValue })
        var seenRemoteIDs: Set<String> = []
        return remote.filter { session in
            if let thread = session.threadId?.rawValue {
                guard !seenThreads.contains(thread) else { return false }
                seenThreads.insert(thread)
                return true
            }
            return seenRemoteIDs.insert(session.id).inserted
        }
    }
}
