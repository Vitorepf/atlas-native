import SwiftUI
import AtlasCore

// Engine rows — peel de ArenaIndexSection+Content.

extension ArenaIndexSection {
    @ViewBuilder
    var engineRows: some View {
        ForEach(composite.engines) { engine in
            if let onEngineTap {
                Button { onEngineTap(engine) } label: {
                    ArenaEngineIndexRow(engine: engine, reduceMotion: reduceMotion)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(engineRowSpoken(engine))
                .accessibilityHint("abre detalhe do motor")
            } else {
                ArenaEngineIndexRow(engine: engine, reduceMotion: reduceMotion)
            }
        }
    }
}
