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

    private var indexContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader
            ForEach(composite.engines) { engine in
                if let onEngineTap {
                    Button { onEngineTap(engine) } label: {
                        ArenaEngineIndexRow(engine: engine, reduceMotion: reduceMotion)
                    }
                    .buttonStyle(.plain)
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
    }

    private var chartEngine: AtlasArenaCompositeEngine? {
        composite.engines.first { engine in
            engine.history.contains { point in
                point.composite != nil || point.withAtlas != nil || point.withoutAtlas != nil
            }
        }
    }

    private var coverageCaption: String {
        let base = "cobertura \(composite.suitesMeasured)/\(composite.suitesTotal)"
        guard composite.suitesMeasured < composite.suitesTotal else { return base }
        return "\(base) · parcial"
    }

    private var sectionHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 3) {
                Text("O ÍNDICE")
                    .font(.system(.caption, weight: .semibold))
                    .tracking(1.4)
                    .foregroundStyle(AtlasTheme.textTertiary)
                Text(coverageCaption)
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            Spacer()
            if !composite.weightsPublic.isEmpty {
                Text("\(composite.weightsPublic.count) pesos")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .accessibilityLabel("\(composite.weightsPublic.count) pesos públicos")
            }
        }
    }
}
