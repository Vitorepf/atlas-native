import SwiftUI
import AtlasCore

/// Frota medida — ranking editorial de todos os motores (com vs sem Atlas).
/// Dados: `composite.engines` apenas; ausência = “não medido”, nunca zero.
struct ArenaPremiumFleetView: View {
    @Bindable var model: ArenaModel

    private var engines: [AtlasArenaCompositeEngine] {
        let raw = model.composite?.engines ?? []
        return raw.sorted { lhs, rhs in
            switch (lhs.atlasMultiplier, rhs.atlasMultiplier) {
            case let (l?, r?): return l > r
            case (_?, nil): return true
            case (nil, _?): return false
            case (nil, nil):
                switch (lhs.composite, rhs.composite) {
                case let (l?, r?): return l > r
                case (_?, nil): return true
                case (nil, _?): return false
                default: return lhs.engine < rhs.engine
                }
            }
        }
    }

    private var best: AtlasArenaCompositeEngine? {
        engines.first { $0.atlasMultiplier != nil && ($0.atlasMultiplier ?? 0) > 0 }
            ?? engines.first { $0.composite != nil }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            header
            if engines.isEmpty {
                empty
            } else {
                ForEach(engines) { engine in
                    fleetRow(engine, highlight: engine.id == best?.id)
                }
            }
        }
        .accessibilityIdentifier(A11yID.arenaPremiumFleet)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            ArenaPremiumKicker(
                text: "Frota medida · \(engines.count) \(engines.count == 1 ? "motor" : "motores")"
            )
            Text("Onde o Atlas sobe")
                .font(AtlasFont.serif(31))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            if let best, let mult = best.atlasMultiplier {
                Text("melhor ganho · \(ArenaDisplay.engine(best.engine)) · \(ArenaFormat.multiplier(mult))")
                    .font(AtlasFont.serifItalic(15))
                    .foregroundStyle(AtlasTheme.accent)
            }
        }
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: 14) {
            ArenaPremiumEmptyGlyph(symbol: "gauge.with.dots.needle.33percent")
            Text("Nenhum motor medido")
                .font(AtlasFont.serif(28))
                .foregroundStyle(AtlasTheme.textPrimary)
            Text("Rode uma medição com pelo menos um motor para ver o ranking da frota.")
                .font(.system(.callout))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 12)
    }

    private func fleetRow(_ engine: AtlasArenaCompositeEngine, highlight: Bool) -> some View {
        let without = engine.withoutAtlasComposite
        let withAtlas = engine.withAtlasComposite
        let maxScore = max(without ?? 0, withAtlas ?? 0, 10)
        return VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(ArenaDisplay.engine(engine.engine))
                    .atlasSans(15, .medium)
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .lineLimit(1)
                Spacer(minLength: 8)
                multiplierLabel(engine)
            }
            if without != nil || withAtlas != nil {
                bar(label: "sem", value: without, ceiling: maxScore, atlas: false)
                bar(label: "Atlas", value: withAtlas, ceiling: maxScore, atlas: true)
            } else {
                Text("não medido")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            ArenaPremiumHairline()
        }
        .padding(.top, highlight ? 2 : 0)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(fleetSpoken(engine))
        .accessibilityIdentifier(A11yID.arenaPremiumFleetRow(engine.engine))
    }

    @ViewBuilder
    private func multiplierLabel(_ engine: AtlasArenaCompositeEngine) -> some View {
        if let mult = engine.atlasMultiplier {
            Text(ArenaFormat.multiplier(mult))
                .font(AtlasFont.mono(11, .medium))
                .foregroundStyle(mult >= 1 ? AtlasTheme.accent : AtlasTheme.alert)
        } else if engine.composite == nil {
            Text("não medido")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textTertiary)
        }
    }

    private func bar(label: String, value: Double?, ceiling: Double, atlas: Bool) -> some View {
        let fraction: CGFloat = {
            guard let value, ceiling > 0 else { return 0 }
            return CGFloat(min(Swift.max(value / ceiling, 0), 1))
        }()
        return HStack(spacing: 10) {
            Text(label)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .frame(width: 44, alignment: .leading)
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.06))
                        .frame(height: 2)
                    Capsule()
                        .fill(atlas ? AtlasTheme.accent : AtlasTheme.textSecondary.opacity(0.55))
                        .frame(width: Swift.max(geo.size.width * fraction, value == nil ? 0 : 2), height: 2)
                }
                .frame(maxHeight: .infinity, alignment: .center)
            }
            .frame(height: 14)
            Text(ArenaFormat.score(value))
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 36, alignment: .trailing)
        }
        .accessibilityHidden(true)
    }

    private func fleetSpoken(_ engine: AtlasArenaCompositeEngine) -> String {
        let name = ArenaDisplay.engine(engine.engine)
        if let mult = engine.atlasMultiplier {
            return "\(name), multiplicador \(ArenaFormat.multiplier(mult)), sem Atlas \(ArenaFormat.score(engine.withoutAtlasComposite)), com Atlas \(ArenaFormat.score(engine.withAtlasComposite))"
        }
        return "\(name), não medido"
    }
}
