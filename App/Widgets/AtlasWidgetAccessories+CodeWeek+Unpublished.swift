import WidgetKit
import SwiftUI
import AtlasCore

// Code week unpublished empty — peel de AtlasWidgetAccessories+CodeWeek.

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
