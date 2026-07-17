import SwiftUI
import AtlasCore

// Index chart — peel de ArenaIndexSection+Content.

extension ArenaIndexSection {
    @ViewBuilder
    var indexContentChart: some View {
        if let engine = chartEngine {
            ArenaCompositeChart(engine: engine, reduceMotion: reduceMotion)
                .frame(height: 170)
                .padding(.top, 4)
        }
    }
}
