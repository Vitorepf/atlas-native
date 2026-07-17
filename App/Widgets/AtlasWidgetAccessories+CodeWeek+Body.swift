import WidgetKit
import SwiftUI
import AtlasCore

// Corpo da semana — peel de CodeWeekWidgetView.
// Stack → AtlasWidgetAccessories+CodeWeek+Body+Stack.swift
// A11y → AtlasWidgetAccessories+CodeWeek+Body+A11y.swift

extension CodeWeekWidgetView {
    @ViewBuilder
    func weekBody(week: AtlasNativeSnapshot.Week, stale: Bool, age: String) -> some View {
        weekBodyA11y(weekBodyStack(week: week, stale: stale, age: age), week: week, stale: stale, age: age)
    }
}
