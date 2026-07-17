import SwiftUI
import AtlasCore

// O cockpit da execução — faixa no composer, ribbon, narrativa viva e a
// prova persistente. Extraído de ConversationView (mesma linguagem, arquivo próprio).
// Agentes/banners → ConversationCockpit+Agents.swift; ribbon → ConversationCockpit+Ribbon.swift.

struct ExecutingStrip: View {
    let bubble: ChatBubble
    let reduceMotion: Bool
    let onStop: () -> Void
    var onSteer: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 8) {
            BreathingDiamond(size: 8, reduceMotion: reduceMotion)
            if let p = bubble.executionProgress {
                Text("\(p.current)/\(p.total) · \(p.title)")
                    .font(.system(.footnote)).foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .layoutPriority(2)
            } else if let act = bubble.currentActivity {
                HStack(spacing: 5) {
                    Image(systemName: activityIcon(act.kind))
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(AtlasTheme.accent.opacity(0.85))
                        .accessibilityHidden(true)
                    Text(act.title)
                        .font(.system(.footnote))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .layoutPriority(2)
                }
            } else {
                Text("Seguindo a execução")
                    .font(.system(.footnote)).foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(1)
                    .layoutPriority(2)
            }
            TimelineView(.periodic(from: .now, by: 1)) { ctx in
                let secs = bubble.startedAt.map { max(0, Int(ctx.date.timeIntervalSince($0))) } ?? 0
                Text("· \(bubble.activities.count) evento\(bubble.activities.count == 1 ? "" : "s") · \(secs)s")
                    .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                    .monospacedDigit()
                    .modifier(NumericTextTransition(enabled: !reduceMotion))
                    .lineLimit(1)
            }
            if let stats = bubble.diffStats {
                Text("+\(stats.linesAdded) −\(stats.linesRemoved)")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.accent)
                    .lineLimit(1)
                    .accessibilityLabel("mais \(stats.linesAdded), menos \(stats.linesRemoved) linhas")
            }
            Spacer(minLength: 0)
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
            }
            Button(action: onStop) {
                Text("Parar")
                    .font(.system(.footnote, weight: .medium))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .lineLimit(1)
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel("parar execução")
        }
        .padding(.horizontal, 6)
        .lineLimit(1)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(stripAccessibilityLabel)
    }

    private var stripAccessibilityLabel: String {
        if let p = bubble.executionProgress {
            return "execução ao vivo, passo \(p.current) de \(p.total), \(p.title)"
        }
        if let act = bubble.currentActivity {
            return "execução ao vivo, \(act.title), \(bubble.activities.count) eventos"
        }
        return "seguindo a execução, \(bubble.activities.count) eventos"
    }
}
