import SwiftUI
import AtlasCore

// A11y label — peel de ExecutingStrip (régua ≤100).

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
