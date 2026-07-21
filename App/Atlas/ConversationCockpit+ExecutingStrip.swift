import SwiftUI
import AtlasCore

// MARK: - Conversation live instrument (WAVE-006)
// Uma árvore visual: live · progress · reconnect · stop · steer.
// Reconnect banner (cockpit) e silence watchdog continuam secondary surfaces.

struct ExecutingStrip: View {
    let bubble: ChatBubble
    let reduceMotion: Bool
    let onStop: () -> Void
    var onSteer: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 8) {
            stripStatus
            Spacer(minLength: 0)
            stripActionButtons
        }
        .padding(.horizontal, 6)
        .lineLimit(1)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.executionLiveStrip)
    }

    // MARK: Status

    @ViewBuilder
    var stripStatus: some View {
        HStack(spacing: 8) {
            stripStatusLeading
            stripStatusTitle
            stripStatusMeta
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(stripAccessibilityLabel)
    }

    @ViewBuilder
    var stripStatusLeading: some View {
        if bubble.showsReconnectSurface {
            Image(systemName: bubble.reconnectBannerIcon)
                .atlasSans(10, .semibold)
                .foregroundStyle(AtlasTheme.textSecondary)
                .symbolEffect(.pulse, options: .repeating, isActive: !reduceMotion)
                .accessibilityHidden(true)
        } else {
            BreathingDiamond(size: 8, reduceMotion: reduceMotion)
        }
    }

    @ViewBuilder
    var stripStatusTitle: some View {
        if bubble.showsReconnectSurface || bubble.executionProgress != nil {
            stripStatusReconnectOrProgress
        } else {
            stripStatusActivityOrIdle
        }
    }

    @ViewBuilder
    var stripStatusReconnectOrProgress: some View {
        if bubble.showsReconnectSurface, let line = bubble.reconnectPrimaryLine {
            Text(line)
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(1)
                .truncationMode(.tail)
                .layoutPriority(2)
                .accessibilityHidden(true)
        } else if let p = bubble.executionProgress {
            Text("\(p.current)/\(p.total) · \(p.title)")
                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(1)
                .truncationMode(.tail)
                .layoutPriority(2)
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    var stripStatusActivityOrIdle: some View {
        if let act = bubble.currentActivity {
            HStack(spacing: 5) {
                Image(systemName: activityIcon(act.kind))
                    .atlasSans(10, .semibold)
                    .foregroundStyle(AtlasTheme.accent.opacity(0.85))
                    .accessibilityHidden(true)
                Text(act.title)
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .layoutPriority(2)
                    .accessibilityHidden(true)
            }
        } else {
            Text("Seguindo a execução")
                .font(.system(.footnote)).foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(1)
                .layoutPriority(2)
                .accessibilityHidden(true)
        }
    }

    @ViewBuilder
    var stripStatusMeta: some View {
        TimelineView(.periodic(from: .now, by: 1)) { ctx in
            let secs = bubble.startedAt.map { max(0, Int(ctx.date.timeIntervalSince($0))) } ?? 0
            Text("· \(bubble.activities.count) evento\(bubble.activities.count == 1 ? "" : "s") · \(secs)s")
                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
                .modifier(NumericTextTransition(enabled: !reduceMotion))
                .lineLimit(1)
                .accessibilityHidden(true)
        }
        if let stats = bubble.diffStats {
            Text("+\(stats.linesAdded) −\(stats.linesRemoved)")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.accent)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }

    // MARK: Actions

    @ViewBuilder
    var stripActionButtons: some View {
        if let onSteer {
            Button(action: onSteer) {
                Text("Redirecionar")
                    .font(.system(.footnote, weight: .medium))
                    .foregroundStyle(AtlasTheme.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel("redirecionar execução")
            .accessibilityHint("abre opções para redirecionar a execução ao vivo")
        }
        Button(action: onStop) {
            Text("Parar")
                .font(.system(.footnote, weight: .medium))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(1)
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel("parar execução")
        .accessibilityHint("interrompe a execução ao vivo")
    }

    // MARK: A11y (phase-aligned compound label)

    var stripAccessibilityLabel: String {
        var parts: [String] = []
        if bubble.showsReconnectSurface {
            parts.append(bubble.reconnectSpokenLabel)
        } else if let p = bubble.executionProgress {
            parts.append("execução ao vivo, passo \(p.current) de \(p.total), \(p.title)")
        } else if let act = bubble.currentActivity {
            parts.append("execução ao vivo, \(act.title)")
        } else {
            parts.append("seguindo a execução")
        }
        let events = bubble.activities.count
        parts.append("\(events) evento\(events == 1 ? "" : "s")")
        if let started = bubble.startedAt {
            let secs = max(0, Int(Date().timeIntervalSince(started)))
            parts.append("\(secs) segundos decorridos")
        }
        if let stats = bubble.diffStats {
            parts.append("mais \(stats.linesAdded), menos \(stats.linesRemoved) linhas")
        }
        return parts.joined(separator: ", ")
    }
}
