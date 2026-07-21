import AtlasCore
import SwiftUI

// Cycle 045 fuse → ExecutingStrip.swift

extension ExecutingStrip {
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
        parts.append(contentsOf: stripAccessibilityExtras())
        return parts.joined(separator: ", ")
    }
}

extension ExecutingStrip {
    func stripAccessibilityExtras() -> [String] {
        var parts: [String] = []
        let events = bubble.activities.count
        parts.append("\(events) evento\(events == 1 ? "" : "s")")
        if let started = bubble.startedAt {
            let secs = max(0, Int(Date().timeIntervalSince(started)))
            parts.append("\(secs) segundos decorridos")
        }
        if let stats = bubble.diffStats {
            parts.append("mais \(stats.linesAdded), menos \(stats.linesRemoved) linhas")
        }
        return parts
    }
}

extension ExecutingStrip {
    @ViewBuilder
    var stripActionButtons: some View {
        steerActionButton
        Button {
            // Medium: interrupts live execution (control commit class).
            AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            onStop()
        } label: {
            Text("Parar")
                .font(.system(.footnote, weight: .medium))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(1)
                .frame(minHeight: 44)
                .contentShape(Rectangle())
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel("parar execução")
        .accessibilityHint("interrompe a execução ao vivo")
    }
}

extension ExecutingStrip {
    @ViewBuilder
    var steerActionButton: some View {
        if let onSteer {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onSteer()
            } label: {
                Text("Redirecionar")
                    .font(.system(.footnote, weight: .medium))
                    .foregroundStyle(AtlasTheme.accent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
                    .frame(minHeight: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(PressableScale())
            .accessibilityLabel("redirecionar execução")
            .accessibilityHint("abre opções para redirecionar a execução ao vivo")
        }
    }
}
