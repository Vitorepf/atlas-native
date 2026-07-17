import WidgetKit
import SwiftUI
import AtlasCore

// Snapshot helpers — peel de AtlasWidgetViews.
// Relative → AtlasWidgetViews+Age+Relative.swift

extension AtlasNativeSnapshot {
    func isStale(at now: Date) -> Bool {
        now.timeIntervalSince(generatedAt) > 6 * 60 * 60
    }

    func ageText(at now: Date) -> String {
        generatedAt.relativeShort(to: now)
    }
}
