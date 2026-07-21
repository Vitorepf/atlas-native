import WidgetKit
import SwiftUI
import AtlasCore

// IDLE-COMPRESS — CodeWeek accessory widget fused

// --- AtlasWidgetAccessories+CodeWeek+A11y.swift ---
enum CodeWeekWidgetA11y {}

// --- AtlasWidgetAccessories+CodeWeek+A11yQuiet.swift ---
extension CodeWeekWidgetA11y {
    static func isQuiet(_ week: AtlasNativeSnapshot.Week) -> Bool {
        week.commits == 0 && week.heals == 0 && week.prevented == 0
    }
}

// --- AtlasWidgetAccessories+CodeWeek+A11ySpokenLabel+Active.swift ---
extension CodeWeekWidgetA11y {
    static func spokenActiveWeekParts(_ week: AtlasNativeSnapshot.Week) -> [String] {
        var parts = ["Semana \(week.window)"]
        if week.commits > 0 { parts.append("\(week.commits) commit\(week.commits == 1 ? "" : "s")") }
        if week.heals > 0 { parts.append("\(week.heals) cura\(week.heals == 1 ? "" : "s")") }
        if week.prevented > 0 { parts.append("\(week.prevented) prevenido\(week.prevented == 1 ? "" : "s")") }
        return parts
    }
}

// --- AtlasWidgetAccessories+CodeWeek+A11ySpokenLabel+Quiet.swift ---
extension CodeWeekWidgetA11y {
    static func spokenQuietWeekParts(_ week: AtlasNativeSnapshot.Week) -> [String] {
        ["Semana \(week.window), semana quieta, sem commits nem curas"]
    }
}

// --- AtlasWidgetAccessories+CodeWeek+A11ySpokenLabel.swift ---
extension CodeWeekWidgetA11y {
    static func spokenLabel(week: AtlasNativeSnapshot.Week, stale: Bool, age: String) -> String {
        var parts = isQuiet(week)
            ? spokenQuietWeekParts(week)
            : spokenActiveWeekParts(week)
        if stale { parts.append("visto \(age)") }
        return parts.joined(separator: ", ")
    }
}

// --- AtlasWidgetAccessories+CodeWeek+Body+A11y.swift ---
extension CodeWeekWidgetView {
    func weekBodyA11y<V: View>(
        _ content: V,
        week: AtlasNativeSnapshot.Week,
        stale: Bool,
        age: String
    ) -> some View {
        content
            .accessibilityElement(children: .combine)
            .accessibilityLabel(CodeWeekWidgetA11y.spokenLabel(week: week, stale: stale, age: age))
    }
}

// --- AtlasWidgetAccessories+CodeWeek+Body+Stack.swift ---
extension CodeWeekWidgetView {
    @ViewBuilder
    func weekBodyStack(week: AtlasNativeSnapshot.Week, stale: Bool, age: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            weekHeader(week: week, stale: stale, age: age)
            weekMetricsOrQuiet(week)
            weekLargeHint(week)
            Spacer(minLength: 0)
        }
    }
}

// --- AtlasWidgetAccessories+CodeWeek+Body.swift ---
extension CodeWeekWidgetView {
    @ViewBuilder
    func weekBody(week: AtlasNativeSnapshot.Week, stale: Bool, age: String) -> some View {
        weekBodyA11y(weekBodyStack(week: week, stale: stale, age: age), week: week, stale: stale, age: age)
    }
}

// --- AtlasWidgetAccessories+CodeWeek+EntryGate+Published.swift ---
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

// --- AtlasWidgetAccessories+CodeWeek+EntryGate.swift ---
extension CodeWeekWidgetView {
    @ViewBuilder
    func codeWeekEntryView(snapshot: AtlasNativeSnapshot?) -> some View {
        if let snapshot {
            codeWeekPublishedView(snapshot: snapshot)
        } else {
            InstallPromptView()
        }
    }
}

// --- AtlasWidgetAccessories+CodeWeek+Header+StaleLine.swift ---
extension CodeWeekWidgetView {
    @ViewBuilder
    func weekHeaderStaleLine(stale: Bool, age: String) -> some View {
        if stale {
            Text("visto \(age)")
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(Ink.alert)
        }
    }
}

// --- AtlasWidgetAccessories+CodeWeek+Header+TitleRow.swift ---
extension CodeWeekWidgetView {
    @ViewBuilder
    func weekHeaderTitleRow(week: AtlasNativeSnapshot.Week) -> some View {
        HStack {
            Text("✦ Semana")
                .font(.system(size: 14, weight: .semibold, design: .serif))
            Spacer()
            Text(week.window)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(Ink.ink2)
        }
    }
}

// --- AtlasWidgetAccessories+CodeWeek+Header.swift ---
extension CodeWeekWidgetView {
    @ViewBuilder
    func weekHeader(week: AtlasNativeSnapshot.Week, stale: Bool, age: String) -> some View {
        weekHeaderTitleRow(week: week)
        weekHeaderStaleLine(stale: stale, age: age)
    }
}

// --- AtlasWidgetAccessories+CodeWeek+Hint.swift ---
extension CodeWeekWidgetView {
    @ViewBuilder
    func weekLargeHint(_ week: AtlasNativeSnapshot.Week) -> some View {
        if family == .systemLarge {
            Text(CodeWeekWidgetA11y.isQuiet(week)
                 ? "abra o radar do Código para ver o grafo"
                 : "abra o radar do Código para o grafo")
                .font(.system(size: 12, design: .serif))
                .foregroundStyle(Ink.ink2)
        }
    }
}

// --- AtlasWidgetAccessories+CodeWeek+Metric.swift ---
extension CodeWeekWidgetView {
    func weekMetric(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.system(size: 22, weight: .semibold, design: .monospaced))
                .foregroundStyle(Ink.ink)
            Text(label)
                .font(.system(size: 10, design: .serif))
                .foregroundStyle(Ink.ink2)
        }
    }
}

// --- AtlasWidgetAccessories+CodeWeek+Quiet+MetricsStack+Primary.swift ---
extension CodeWeekWidgetView {
    @ViewBuilder
    func weekMetricsPrimary(_ week: AtlasNativeSnapshot.Week) -> some View {
        if week.commits > 0 { weekMetric("\(week.commits)", "commits") }
        if week.heals > 0 { weekMetric("\(week.heals)", "curas") }
    }
}

// --- AtlasWidgetAccessories+CodeWeek+Quiet+MetricsStack.swift ---
extension CodeWeekWidgetView {
    @ViewBuilder
    func weekMetricsStack(_ week: AtlasNativeSnapshot.Week) -> some View {
        HStack(spacing: 14) {
            weekMetricsPrimary(week)
            if week.prevented > 0 { weekMetric("\(week.prevented)", "prevenidos") }
        }
    }
}

// --- AtlasWidgetAccessories+CodeWeek+Quiet+QuietBranch.swift ---
extension CodeWeekWidgetView {
    @ViewBuilder
    func weekQuietBranch() -> some View {
        Text("semana quieta · sem commits nem curas")
            .font(.system(size: 16, weight: .semibold, design: .serif))
            .foregroundStyle(Ink.ink2)
            .lineLimit(2)
    }
}

// --- AtlasWidgetAccessories+CodeWeek+Quiet.swift ---
extension CodeWeekWidgetView {
    @ViewBuilder
    func weekMetricsOrQuiet(_ week: AtlasNativeSnapshot.Week) -> some View {
        if CodeWeekWidgetA11y.isQuiet(week) {
            weekQuietBranch()
        } else {
            weekMetricsStack(week)
        }
    }
}

// --- AtlasWidgetAccessories+CodeWeek+Unpublished.swift ---
extension CodeWeekWidgetView {
    var unpublishedWeek: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("✦ Semana")
                .font(.system(size: 14, weight: .semibold, design: .serif))
            Text("semana ainda não publicada")
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundStyle(Ink.ink2)
            Spacer(minLength: 0)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("semana ainda não publicada")
    }
}

// --- AtlasWidgetAccessories+CodeWeek.swift ---
struct CodeWeekWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: SnapshotEntry

    var body: some View {
        SnapshotContainer {
            AnyView(codeWeekEntryView(snapshot: entry.snapshot))
        }
        .widgetURL(URL(string: "atlas://code"))
    }
}
