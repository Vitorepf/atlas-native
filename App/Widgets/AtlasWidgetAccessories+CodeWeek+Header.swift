import WidgetKit
import SwiftUI
import AtlasCore

// Week header — peel de AtlasWidgetAccessories+CodeWeek+Body.
// Title → AtlasWidgetAccessories+CodeWeek+Header+TitleRow.swift
// Stale → AtlasWidgetAccessories+CodeWeek+Header+StaleLine.swift

extension CodeWeekWidgetView {
    @ViewBuilder
    func weekHeader(week: AtlasNativeSnapshot.Week, stale: Bool, age: String) -> some View {
        weekHeaderTitleRow(week: week)
        weekHeaderStaleLine(stale: stale, age: age)
    }
}
