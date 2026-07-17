import WidgetKit
import SwiftUI
import AtlasCore

// Snapshot entry gate — peel de AtlasWidgetAccessories+CodeWeek.

extension CodeWeekWidgetView {
    @ViewBuilder
    func codeWeekEntryView(snapshot: AtlasNativeSnapshot?) -> some View {
        if let snapshot, let week = snapshot.week {
            let stale = snapshot.isStale(at: entry.date)
            weekBody(week: week, stale: stale, age: snapshot.ageText(at: entry.date))
        } else if entry.snapshot != nil {
            unpublishedWeek
        } else {
            InstallPromptView()
        }
    }
}
