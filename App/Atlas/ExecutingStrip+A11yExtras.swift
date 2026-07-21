import AtlasCore
import SwiftUI

// Cycle 041 fuse → ExecutingStrip+A11yExtras.swift

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
}
