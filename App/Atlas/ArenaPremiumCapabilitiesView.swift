import SwiftUI
import AtlasCore

struct ArenaPremiumCapabilitiesView: View {
    @Bindable var model: ArenaModel
    let onCapability: (AtlasArenaCapability) -> Void

    private var capabilities: [AtlasArenaCapability] {
        model.selectedCapabilities?.capabilities ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            capabilityHeader
            enginePicker
            if capabilities.isEmpty {
                empty
            } else {
                summary
                rows
            }
        }
        // Ao abrir a aba, re-busca do servidor: o poll de 10s não recarrega
        // capacidades, então sem isto a tela ficava com dado velho (o -8,3
        // falso onde o servidor já diz "não medido").
        .task { await model.refreshCapabilities() }
    }

    @ViewBuilder
    private var enginePicker: some View {
        if model.capabilityEngineOptions.count > 1 {
            Menu {
                ForEach(model.capabilityEngineOptions, id: \.self) { engine in
                    Button(ArenaDisplay.engine(engine)) {
                        model.capabilitiesEngineSelection = engine
                    }
                }
            } label: {
                HStack(spacing: 7) {
                    ArenaPremiumIcon(
                        symbol: "chevron.up.chevron.down",
                        tone: .neutral,
                        role: .compact
                    )
                    Text("Trocar motor")
                }
                    .font(AtlasFont.mono(10, .medium))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
        }
    }

    private var capabilityHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            ArenaPremiumKicker(text: "Perfil medido · escala 0–10", tone: .active)
                .accessibilityIdentifier(A11yID.arenaPremiumCapabilities)
            Text(ArenaDisplay.engine(model.selectedCapabilities?.engine ?? model.preferredEngine ?? "motor"))
                .font(AtlasFont.serif(33))
                .foregroundStyle(AtlasTheme.textPrimary)
            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text("\(measuredCount)")
                    .font(AtlasFont.serif(56))
                Text("/\(capabilities.count)")
                    .font(AtlasFont.serif(29))
                Text("capacidades cobertas")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .padding(.leading, 6)
            }
            .foregroundStyle(AtlasTheme.textPrimary)
        }
    }

    private var summary: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 24) {
                summaryMetric(improvedCount, "melhoraram", .positive)
                summaryMetric(stableCount, "estáveis", .neutral)
                summaryMetric(regressedCount, "regrediram", .negative)
            }
            VStack(alignment: .leading, spacing: 10) {
                summaryMetric(improvedCount, "melhoraram", .positive)
                summaryMetric(stableCount, "estáveis", .neutral)
                summaryMetric(regressedCount, "regrediram", .negative)
            }
        }
    }

    private var rows: some View {
        VStack(spacing: 0) {
            ArenaPremiumHairline()
            ForEach(capabilities) { capability in
                Button { onCapability(capability) } label: {
                    // Sem numeral: a lista não é sequência — número que não
                    // codifica nada é ruído (régua da casa).
                    HStack(spacing: 10) {
                        Text(capability.labelPt)
                            .font(.system(.callout))
                            .foregroundStyle(AtlasTheme.textPrimary)
                            .frame(maxWidth: 170, alignment: .leading)
                        ArenaCapabilityTrack(
                            baseline: capability.score,
                            withAtlas: capability.withAtlas
                        )
                        .frame(minWidth: 86)
                        deltaLabel(capability)
                        ArenaPremiumChevron()
                    }
                    .frame(minHeight: 58)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(capabilitySpoken(capability))
                .accessibilityIdentifier(A11yID.arenaCapabilityRow(capability.capability))
                ArenaPremiumHairline()
            }
            Text("Cada capacidade abre as suítes e os casos que contribuíram para a medida.")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .padding(.top, 16)
        }
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: 16) {
            ArenaPremiumEmptyGlyph(symbol: "shield.lefthalf.filled")
            Text("Capacidades ainda não medidas")
                .font(AtlasFont.serif(29))
                .foregroundStyle(AtlasTheme.textPrimary)
            Text("Ausência permanece ausência — nenhuma barra começa em zero.")
                .font(.system(.callout))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
    }

    private var measuredCount: Int {
        capabilities.count { $0.score != nil && $0.withAtlas != nil }
    }

    private var improvedCount: Int { capabilities.count { delta($0).map { $0 > 0.005 } == true } }
    private var regressedCount: Int { capabilities.count { delta($0).map { $0 < -0.005 } == true } }
    private var stableCount: Int { max(0, measuredCount - improvedCount - regressedCount) }

    private func delta(_ capability: AtlasArenaCapability) -> Double? {
        guard let baseline = capability.score, let withAtlas = capability.withAtlas else { return nil }
        return withAtlas - baseline
    }

    private func summaryMetric(_ value: Int, _ label: String, _ tone: ArenaPremiumTone) -> some View {
        HStack(spacing: 6) {
            Text("\(value)").font(AtlasFont.serif(25)).foregroundStyle(tone.color)
            Text(label).font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textSecondary)
        }
    }

    private func deltaLabel(_ capability: AtlasArenaCapability) -> some View {
        let value = delta(capability)
        return Text(ArenaFormat.signed(value))
            .font(AtlasFont.mono(10, .medium))
            .foregroundStyle(deltaColor(value))
            .frame(width: 44, alignment: .trailing)
    }

    private func deltaColor(_ value: Double?) -> Color {
        guard let value else { return AtlasTheme.textTertiary }
        if abs(value) <= 0.005 { return AtlasTheme.textSecondary }
        return value > 0 ? AtlasTheme.textPrimary : AtlasTheme.alert
    }

    private func capabilitySpoken(_ capability: AtlasArenaCapability) -> String {
        "\(capability.labelPt), sem Atlas \(ArenaFormat.score(capability.score)), com Atlas \(ArenaFormat.score(capability.withAtlas)), diferença \(ArenaFormat.signed(delta(capability)))"
    }
}

struct ArenaCapabilityTrack: View {
    let baseline: Double?
    let withAtlas: Double?

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule().fill(AtlasTheme.separator).frame(height: 2)
                marker(baseline, color: AtlasTheme.textSecondary, filled: false, width: proxy.size.width)
                marker(withAtlas, color: AtlasTheme.accent, filled: true, width: proxy.size.width)
            }
        }
        .frame(height: 18)
        .accessibilityHidden(true)
    }

    @ViewBuilder
    private func marker(_ value: Double?, color: Color, filled: Bool, width: CGFloat) -> some View {
        if let value {
            Circle()
                .fill(filled ? color : AtlasTheme.bg)
                .overlay(Circle().stroke(color, lineWidth: 2))
                .frame(width: 12, height: 12)
                .offset(x: max(0, min(width - 12, width * value - 6)))
        }
    }
}
