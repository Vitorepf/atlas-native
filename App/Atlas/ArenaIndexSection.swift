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

    var chartEngine: AtlasArenaCompositeEngine? {
        composite.engines.first { engine in
            engine.history.contains { point in
                point.composite != nil || point.withAtlas != nil || point.withoutAtlas != nil
            }
        }
    }

    var coverageCaption: String {
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
                    .accessibilityHidden(true)
                Text(coverageCaption)
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            Spacer()
            if !composite.weightsPublic.isEmpty {
                Text("\(composite.weightsPublic.count) pesos")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .accessibilityHidden(true)
            }
        }
    }
}
