import WidgetKit
import SwiftUI
import AtlasCore

// Snapshot container — peel de AtlasWidgetViews.

struct SnapshotContainer<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            Ink.bg
            content()
                .foregroundStyle(Ink.ink)
                .padding(14)
        }
        .containerBackground(Ink.bg, for: .widget)
    }
}
