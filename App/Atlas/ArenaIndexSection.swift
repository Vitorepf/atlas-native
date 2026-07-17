import SwiftUI
import AtlasCore

struct ArenaIndexSection: View {
    let composite: AtlasArenaComposite
    let reduceMotion: Bool
    var onEngineTap: ((AtlasArenaCompositeEngine) -> Void)?

    var body: some View {
        if !composite.engines.isEmpty {
            indexContent
        }
    }

    var indexContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader
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
            if let engine = chartEngine {
                ArenaCompositeChart(engine: engine, reduceMotion: reduceMotion)
                    .frame(height: 170)
                    .padding(.top, 4)
            }
        }
        .padding(16)
        .atlasCard()
        .accessibilityElement(children: .contain)
        .accessibilityLabel(sectionSpokenLabel)
        .accessibilityIdentifier(A11yID.arenaIndexSection)
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: composite.engines.map(\.id))
    }
}
