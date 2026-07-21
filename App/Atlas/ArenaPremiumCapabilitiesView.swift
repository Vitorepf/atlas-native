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
            if capabilities.isEmpty {
                empty
            } else {
                summary
                trackLegend
                rows
            }
        }
        // Ao abrir a aba, re-busca do servidor: o poll de 10s não recarrega
        // capacidades, então sem isto a tela ficava com dado velho (o -8,3
        // falso onde o servidor já diz "não medido").
        .task { await model.refreshCapabilities() }
    }

    private var capabilityHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            ArenaPremiumKicker(text: ArenaScoreJudgment.capabilitiesKicker())
                .accessibilityIdentifier(A11yID.arenaPremiumCapabilities)
            ArenaPremiumEngineTitle(
                engineID: model.selectedCapabilities?.engine
                    ?? model.preferredEngine
                    ?? "motor",
                options: model.capabilityEngineOptions,
                onSelect: { model.capabilitiesEngineSelection = $0 }
            )
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

    private var trackLegend: some View {
        HStack(spacing: 16) {
            HStack(spacing: 6) {
                Circle()
                    .stroke(AtlasTheme.textSecondary, lineWidth: 1.5)
                    .frame(width: 8, height: 8)
                Text("sem Atlas")
            }
            HStack(spacing: 5) {
                Text("✦")
                    .font(AtlasFont.serif(11))
                    .foregroundStyle(AtlasTheme.accent)
                Text("com Atlas")
            }
        }
        .font(AtlasFont.mono(10))
        .foregroundStyle(AtlasTheme.textTertiary)
        .accessibilityHidden(true)
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

    /// Ordem fixa dos grupos da taxonomia v2 — decisão editorial, não alfabética:
    /// construir → compreender → manter → operar.
    private static let groupOrder = ["construction", "comprehension", "quality", "agentic"]

    private var rows: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let area = model.selectedCapabilities?.areaLabelPt, !area.isEmpty {
                Text(area.uppercased())
                    .font(AtlasFont.mono(10, .medium))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .padding(.bottom, 10)
            }
            ForEach(Self.groupOrder, id: \.self) { groupKey in
                let members = capabilities.filter { ($0.group ?? "quality") == groupKey }
                if !members.isEmpty {
                    Text(model.selectedCapabilities?.groupsPt?[groupKey] ?? groupKey)
                        .font(AtlasFont.serif(17))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .padding(.top, 14)
                        .padding(.bottom, 4)
                    groupRows(members)
                }
            }
            Text(capabilitiesCaption)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .padding(.top, 16)
        }
    }

    private func groupRows(_ members: [AtlasArenaCapability]) -> some View {
        VStack(spacing: 0) {
            ArenaPremiumHairline()
            ForEach(members) { capability in
                Button { onCapability(capability) } label: {
                    // Sem numeral: a lista não é sequência — número que não
                    // codifica nada é ruído (régua da casa).
                    HStack(spacing: 10) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(capability.labelPt)
                                .font(AtlasFont.serifItalic(15))
                                .foregroundStyle(AtlasTheme.textPrimary)
                            if let caption = shortConfidence(capability) {
                                Text(caption)
                                    .font(AtlasFont.mono(9))
                                    .foregroundStyle(AtlasTheme.textTertiary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                        }
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
        }
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: 16) {
            ArenaPremiumEmptyGlyph(symbol: "shield.lefthalf.filled")
            Text("Capacidades ainda não medidas")
                .font(AtlasFont.serif(29))
                .foregroundStyle(AtlasTheme.textPrimary)
            Text("Ausência permanece ausência — nenhuma barra começa em zero.")
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
    }

    private var capabilitiesCaption: String {
        if model.capabilityEngineOptions.count > 1 {
            return "Toque no nome do motor para ver outro perfil medido. Cada capacidade abre as suítes que alimentaram a medida."
        }
        return "Cada capacidade abre as suítes e os casos que contribuíram para a medida."
    }

    // Lei do operador: número não confiável = não medido, nunca falso. "Coberta"
    // aqui significa MEDIDA com confiança — ter dois pontos na régua não basta
    // (o +4,9 de code_editing com 81% do braço Atlas descartado era exatamente
    // um número de sobrevivência vendido como vitória no topo da tela).
    private var measuredCount: Int {
        capabilities.count { $0.confidenceLevel == .measured }
    }

    // Melhorou/regrediu SÓ com IC de Newcombe fora do zero; medido sem
    // significância é "estável" (dentro do ruído), nunca vitória nem derrota.
    private var improvedCount: Int {
        capabilities.count { $0.confidenceLevel == .measured && $0.delta?.significant == true && ($0.delta?.value ?? 0) > 0 }
    }

    private var regressedCount: Int {
        capabilities.count { $0.confidenceLevel == .measured && $0.delta?.significant == true && ($0.delta?.value ?? 0) < 0 }
    }

    private var stableCount: Int { max(0, measuredCount - improvedCount - regressedCount) }

    private func delta(_ capability: AtlasArenaCapability) -> Double? {
        capability.delta?.value
    }

    /// Sub-rótulo honesto para linha que NÃO é medida — a mesma verdade que a
    /// aba clássica fala via confidenceCaption, na densidade da lista premium.
    private func shortConfidence(_ capability: AtlasArenaCapability) -> String? {
        // Capacidade gated: instrumento em preparação — a razão É a informação.
        if let gated = capability.gatedReason, !gated.isEmpty {
            return gated
        }
        switch capability.confidenceLevel {
        case .measured:
            return capability.delta?.significant == true ? nil : "dentro do ruído"
        case .low:
            let n = capability.withAtlasCases ?? capability.baselineCases ?? 0
            return "poucos casos (N \(n)) · baixa confiança"
        case .unmeasured:
            if let rate = capability.maxExclusionRate, rate >= 0.5 {
                return "\(Int((rate * 100).rounded()))% descartado no setup · não medível"
            }
            return capability.withAtlas == nil ? "Atlas ainda não rodou aqui" : "não medível"
        }
    }

    private func summaryMetric(_ value: Int, _ label: String, _ tone: ArenaPremiumTone) -> some View {
        HStack(spacing: 6) {
            Text("\(value)").font(AtlasFont.serif(25)).foregroundStyle(tone.color)
            Text(label).font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textSecondary)
        }
    }

    private func deltaLabel(_ capability: AtlasArenaCapability) -> some View {
        // Delta como NOTA só quando medido; não-medível vira travessão (o ponto
        // na régua continua visível, mas nenhum número finge veredito).
        let level = capability.confidenceLevel
        let text = level == .unmeasured ? "—" : ArenaFormat.signed(delta(capability))
        return Text(text)
            .font(AtlasFont.mono(10, .medium))
            .foregroundStyle(deltaColor(capability))
            .frame(width: 44, alignment: .trailing)
    }

    private func deltaColor(_ capability: AtlasArenaCapability) -> Color {
        switch capability.confidenceLevel {
        case .unmeasured, .low:
            return AtlasTheme.textTertiary
        case .measured:
            guard capability.delta?.significant == true, let value = delta(capability) else {
                return AtlasTheme.textSecondary
            }
            return value > 0 ? AtlasTheme.textPrimary : AtlasTheme.alert
        }
    }

    private func capabilitySpoken(_ capability: AtlasArenaCapability) -> String {
        let base = "\(capability.labelPt), sem Atlas \(ArenaFormat.score(capability.score)), com Atlas \(ArenaFormat.score(capability.withAtlas)), diferença \(ArenaFormat.signed(delta(capability)))"
        guard let caption = shortConfidence(capability) else { return base }
        return "\(base), \(caption)"
    }
}

struct ArenaCapabilityTrack: View {
    let baseline: Double?
    let withAtlas: Double?

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            ZStack(alignment: .leading) {
                Capsule().fill(AtlasTheme.separator).frame(height: 2)
                // sem Atlas = anel quieto; com Atlas = ✦ da casa (não bola).
                if let baseline {
                    Circle()
                        .fill(AtlasTheme.bg)
                        .overlay(Circle().stroke(AtlasTheme.textSecondary, lineWidth: 1.5))
                        .frame(width: 10, height: 10)
                        .offset(x: max(0, min(w - 10, w * baseline - 5)))
                }
                if let withAtlas {
                    Text("✦")
                        .font(AtlasFont.serif(13))
                        .foregroundStyle(AtlasTheme.accent)
                        .offset(x: max(0, min(w - 13, w * withAtlas - 6.5)))
                }
            }
        }
        .frame(height: 18)
        .accessibilityHidden(true)
    }
}
