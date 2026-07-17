import SwiftUI
import AtlasCore

/// "VIVO AGORA" — a home vira cockpit quando há sessão observada neste
/// processo. Sem sessões a seção não existe (lei V1: estado por exceção).
struct LiveNowSection: View {
    let localSessions: [LiveSessionSnapshot]
    let remoteSessions: [LiveSessionSnapshot]
    let onOpen: (ThreadID, String) -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var sessions: [LiveSessionSnapshot] {
        Self.merged(local: localSessions, remote: remoteSessions)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("VIVO AGORA")
                .font(AtlasFont.mono(11))
                .tracking(1.4)
                .foregroundStyle(AtlasTheme.textTertiary)

            ForEach(Array(sessions.enumerated()), id: \.element.id) { index, session in
                LiveNowRow(
                    session: session,
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

private struct LiveNowRow: View {
    let session: LiveSessionSnapshot
    let reduceMotion: Bool
    let remoteBadgeID: String?
    let onTap: () -> Void

    private var navigable: Bool { session.threadId != nil }

    var body: some View {
        Group {
            if navigable {
                Button(action: onTap) { rowContent }
                    .buttonStyle(PressableScale())
            } else {
                rowContent
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(a11yLabel)
        .accessibilityAddTraits(navigable ? .isButton : [])
    }

    private var rowContent: some View {
        TimelineView(.periodic(from: .now, by: 60)) { context in
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                BreathingDiamond(
                    size: 8,
                    reduceMotion: reduceMotion || session.timing != .running
                )
                VStack(alignment: .leading, spacing: 3) {
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
                        if session.isRemote {
                            remoteBadge
                        }
                        clockView(now: context.date)
                    }
                }
                Spacer(minLength: 0)
                if navigable {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .accessibilityHidden(true)
                }
            }
            .opacity(isLongPaused(now: context.date) ? 0.58 : 1)
        }
    }

    private var remoteBadge: some View {
        Text("em outra superfície")
            .font(AtlasFont.mono(9))
            .tracking(0.4)
            .foregroundStyle(AtlasTheme.accent)
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(Capsule().fill(AtlasTheme.goldVeil))
            .overlay(Capsule().stroke(AtlasTheme.goldBorder, lineWidth: 1))
            .accessibilityIdentifier(remoteBadgeID ?? "")
    }

    @ViewBuilder
    private func clockView(now: Date) -> some View {
        switch session.timing {
        case .running:
            TimelineView(.periodic(from: .now, by: 1)) { context in
                Text(Self.formatClock(
                    elapsedMs: session.elapsedActiveMs,
                    runningSince: session.runningSince,
                    now: context.date,
                    paused: false
                ))
                .font(AtlasFont.serifItalic(13))
                .foregroundStyle(AtlasTheme.textSecondary)
                .monospacedDigit()
            }
        case .paused:
            Text(pausedText(now: now))
                .font(AtlasFont.serifItalic(13))
                .foregroundStyle(AtlasTheme.textSecondary)
                .monospacedDigit()
        case .finished:
            Text("✓ concluído")
                .font(AtlasFont.serifItalic(13))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
    }

    private func pausedText(now: Date) -> String {
        let clock = Self.formatClock(elapsedMs: session.elapsedActiveMs, runningSince: nil, now: now, paused: true)
        guard let age = pauseAgeHours(now: now) else { return "‖ \(clock)" }
        return "‖ \(clock) · há \(age)h"
    }

    private var a11yLabel: String {
        let clock = Self.formatClock(
            elapsedMs: session.elapsedActiveMs,
            runningSince: session.runningSince,
            now: .now,
            paused: session.timing == .paused
        )
        switch session.timing {
        case .running:
            return "\(session.title), \(session.phaseTitle)\(remoteSuffix), em execução há \(clock)"
        case .paused:
            let age = pauseAgeHours(now: .now).map { ", há \($0) horas" } ?? ""
            return "\(session.title), \(session.phaseTitle)\(remoteSuffix), pausado em \(clock)\(age)"
        case .finished:
            return "\(session.title)\(remoteSuffix), concluído"
        }
    }

    private var remoteSuffix: String {
        session.isRemote ? ", em outra superfície" : ""
    }

    private func isLongPaused(now: Date) -> Bool {
        pauseAgeHours(now: now) != nil
    }

    private func pauseAgeHours(now: Date) -> Int? {
        guard session.timing == .paused, let pauseTimestamp = session.pauseTimestamp else { return nil }
        let seconds = max(0, now.timeIntervalSince(pauseTimestamp))
        guard seconds >= 30 * 60 else { return nil }
        return max(1, Int(seconds / 3600))
    }

    /// Relógio canônico: `elapsedActiveMs` + (now − runningSince) quando running.
    /// Paused congela o acumulado. Sem timer do servidor → "—" (ausência ≠ zero).
    private static func formatClock(
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
