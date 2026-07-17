import WidgetKit
import SwiftUI
import AtlasCore

// MARK: - Code week snapshot widget
// Body → AtlasWidgetAccessories+CodeWeek+Body.swift

struct CodeWeekWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: SnapshotEntry

    var body: some View {
        SnapshotContainer {
            guard let snapshot = entry.snapshot else {
                return AnyView(InstallPromptView())
            }
            guard let week = snapshot.week else {
                return AnyView(VStack(alignment: .leading, spacing: 6) {
                    Text("✦ Semana")
                        .font(.system(size: 14, weight: .semibold, design: .serif))
                    Text("semana ainda não publicada")
                        .font(.system(size: 16, weight: .semibold, design: .serif))
                        .foregroundStyle(Ink.ink2)
                    Spacer(minLength: 0)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("semana ainda não publicada"))
            }
            let stale = snapshot.isStale(at: entry.date)
            return AnyView(weekBody(week: week, stale: stale, age: snapshot.ageText(at: entry.date)))
        }
        .widgetURL(URL(string: "atlas://code"))
    }
}
