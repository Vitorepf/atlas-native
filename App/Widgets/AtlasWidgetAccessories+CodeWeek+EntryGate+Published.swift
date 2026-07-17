import WidgetKit
import SwiftUI
import AtlasCore

// Published week gate — peel de CodeWeek EntryGate.

extension CodeWeekWidgetView {
    @ViewBuilder
    func codeWeekPublishedView(snapshot: AtlasNativeSnapshot) -> some View {
        if let week = snapshot.week {
            let stale = snapshot.isStale(at: entry.date)
            weekBody(week: week, stale: stale, age: snapshot.ageText(at: entry.date))
        } else {
            unpublishedWeek
        }
    }
}
