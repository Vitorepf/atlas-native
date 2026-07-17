import WidgetKit
import SwiftUI
import AtlasCore

// Relative age text — peel de AtlasWidgetViews+Age.

extension Date {
    func relativeShort(to now: Date) -> String {
        let seconds = max(0, Int(now.timeIntervalSince(self)))
        if seconds >= 86_400 { return "há \(seconds / 86_400)d" }
        if seconds >= 3_600 { return "há \(seconds / 3_600)h" }
        if seconds >= 60 { return "há \(seconds / 60)m" }
        return "agora"
    }
}
