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


/// Uma linha do Session Hub / VIVO AGORA — title, phase, timing, elapsed.
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
        Group {
            if navigable {
                Button {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    onTap()
                } label: {
                    rowContent
                }
                .buttonStyle(PressableScale())
            } else {
                rowContent
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
        .accessibilityLabel(spokenLabel(hubIndex: hubIndex, hubCount: hubCount))
        .accessibilityHint(navigable ? "abre conversa desta sessão" : "")
        .accessibilityAddTraits(liveNowTraits)
    }

    /// Running sessions update elapsed copy; respect Reduce Motion.
    private var liveNowTraits: AccessibilityTraits {
        let live = session.timing == .running && !reduceMotion
        if navigable {
            return live ? [.isButton, .updatesFrequently] : .isButton
        }
        return live ? .updatesFrequently : []
    }

    private var rowContent: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                HStack(alignment: .firstTextBaseline, spacing: 10) {
                    BreathingDiamond(
                        size: 8,
                        reduceMotion: reduceMotion || session.timing != .running
                    )
                    titleStack(now: context.date)
                }
                Spacer(minLength: 0)
                if navigable {
                    Image(systemName: "chevron.right")
                        .atlasSans(12, .semibold)
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .accessibilityHidden(true)
                }
            }
            .padding(.vertical, 4)
            .frame(minHeight: 44, alignment: .center)
            .opacity(isLongPaused(now: context.date) ? 0.58 : 1)
        }
    }

    private func titleStack(now: Date) -> some View {
        VStack(alignment: .leading, spacing: hubMode ? 4 : 3) {
            Text(session.title)
                .font(AtlasFont.serif(16, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(2)
                .layoutPriority(1)
            HStack(spacing: 6) {
                Text(session.phaseTitle)
                    .font(AtlasFont.serifItalic(13))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(1)
                if session.isRemote { remoteBadge }
            }
            timingLine(now: now)
        }
    }

    private var remoteBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "arrow.triangle.branch")
                .atlasSans(8, .semibold)
                .accessibilityHidden(true)
            Text("remota")
                .font(AtlasFont.mono(9))
                .tracking(0.4)
                .accessibilityHidden(true)
        }
        .foregroundStyle(AtlasTheme.accent)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(Capsule().fill(AtlasTheme.goldVeil))
        .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("sessão remota em outra superfície")
        .accessibilityIdentifier(remoteBadgeID ?? "")
    }

    private func timingLine(now: Date) -> some View {
        HStack(spacing: 6) {
            Text(timingWord)
                .font(AtlasFont.mono(10))
                .tracking(0.3)
                .foregroundStyle(timingColor)
            if session.timing != .finished {
                Text("·")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
                clockView(now: now)
                    .accessibilityLabel(clockAccessibilityLabel(now: now))
            }
            if session.timing == .paused, let age = pauseAgeHours(now: now) {
                Text("· há \(age)h")
                    .font(AtlasFont.serifItalic(12))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
        }
    }

    private var timingWord: String {
        switch session.timing {
        case .running: "em execução"
        case .paused: "pausado"
        case .finished: "concluído"
        }
    }

    private var timingColor: Color {
        switch session.timing {
        case .running: AtlasTheme.accent
        case .paused: AtlasTheme.textTertiary
        case .finished: AtlasTheme.textSecondary
        }
    }

    @ViewBuilder
    private func clockView(now: Date) -> some View {
        switch session.timing {
        case .running:
            TimelineView(.periodic(from: .now, by: reduceMotion ? 60 : 1)) { context in
                clockText(Self.formatClock(
                    elapsedMs: session.elapsedActiveMs,
                    runningSince: session.runningSince,
                    now: context.date,
                    paused: false
                ))
            }
        case .paused:
            clockText(Self.formatClock(
                elapsedMs: session.elapsedActiveMs,
                runningSince: nil,
                now: now,
                paused: true
            ))
        case .finished:
            EmptyView()
        }
    }

    private func clockText(_ value: String) -> some View {
        Text(value)
            .font(AtlasFont.serifItalic(13))
            .foregroundStyle(AtlasTheme.textSecondary)
            .monospacedDigit()
            .modifier(NumericTextTransition(enabled: !reduceMotion))
    }

    private func clockAccessibilityLabel(now: Date) -> String {
        guard let clock = spokenClock(now: now) else {
            return "tempo ativo indisponível"
        }
        return session.timing == .paused
            ? "tempo ativo congelado em \(clock)"
            : "tempo ativo \(clock)"
    }

    // MARK: - Spoken

    private func spokenLabel(hubIndex: Int?, hubCount: Int?, now: Date = .now) -> String {
        let prefix = hubPositionPrefix(index: hubIndex, count: hubCount)
        switch session.timing {
        case .running:
            if let clock = spokenClock(now: now) {
                return "\(prefix)\(session.title), \(session.phaseTitle)\(remoteSuffix), em execução há \(clock)"
            }
            return "\(prefix)\(session.title), \(session.phaseTitle)\(remoteSuffix), em execução, tempo ativo indisponível"
        case .paused:
            let age = pauseAgeHours(now: now).map { ", há \($0) horas" } ?? ""
            if let clock = spokenClock(now: now) {
                return "\(prefix)\(session.title), \(session.phaseTitle)\(remoteSuffix), pausado em \(clock)\(age)"
            }
            return "\(prefix)\(session.title), \(session.phaseTitle)\(remoteSuffix), pausado, tempo ativo indisponível\(age)"
        case .finished:
            return "\(prefix)\(session.title), \(session.phaseTitle)\(remoteSuffix), concluído"
        }
    }

    private var remoteSuffix: String {
        session.isRemote ? ", sessão remota em outra superfície" : ""
    }

    private func hubPositionPrefix(index: Int?, count: Int?) -> String {
        guard let index, let count, count >= 2 else { return "" }
        return "sessão \(index + 1) de \(count), "
    }

    private func spokenClock(now: Date) -> String? {
        guard session.elapsedActiveMs != nil else { return nil }
        return Self.formatClock(
            elapsedMs: session.elapsedActiveMs,
            runningSince: session.runningSince,
            now: now,
            paused: session.timing == .paused
        )
    }

    // MARK: - Pause / clock math

    func pauseAgeHours(now: Date) -> Int? {
        guard session.timing == .paused, let pauseTimestamp = session.pauseTimestamp else { return nil }
        let seconds = max(0, now.timeIntervalSince(pauseTimestamp))
        guard seconds >= 30 * 60 else { return nil }
        return max(1, Int(seconds / 3600))
    }

    func isLongPaused(now: Date) -> Bool {
        pauseAgeHours(now: now) != nil
    }

    /// Relógio canônico: `elapsedActiveMs` + (now − runningSince) quando running.
    static func formatClock(
        elapsedMs: Int?,
        runningSince: Date?,
        now: Date,
        paused: Bool
    ) -> String {
        guard let base = elapsedMs else { return "—" }
        var ms = base
        if !paused, let since = runningSince {
            ms += max(0, Int(now.timeIntervalSince(since) * 1000))
        }
        let s = ms / 1000
        return s >= 3600
            ? String(format: "%d:%02d:%02d", s / 3600, (s % 3600) / 60, s % 60)
            : String(format: "%d:%02d", s / 60, s % 60)
    }
}
