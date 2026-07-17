import WidgetKit
import SwiftUI
import AtlasCore

// Snapshot helpers — peel de AtlasWidgetViews.

extension AtlasNativeSnapshot {
    func isStale(at now: Date) -> Bool {
        now.timeIntervalSince(generatedAt) > 6 * 60 * 60
    }

    func ageText(at now: Date) -> String {
        generatedAt.relativeShort(to: now)
    }
}

extension Date {
    func relativeShort(to now: Date) -> String {
        let seconds = max(0, Int(now.timeIntervalSince(self)))
        if seconds >= 86_400 { return "há \(seconds / 86_400)d" }
        if seconds >= 3_600 { return "há \(seconds / 3_600)h" }
        if seconds >= 60 { return "há \(seconds / 60)m" }
        return "agora"
    }
}
