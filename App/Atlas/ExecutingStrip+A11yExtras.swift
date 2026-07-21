import SwiftUI
import AtlasCore

// Strip a11y extras — peel de ExecutingStrip+A11y.

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
