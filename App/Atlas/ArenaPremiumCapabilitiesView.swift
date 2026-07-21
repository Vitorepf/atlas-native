import SwiftUI
import AtlasCore

struct ArenaPremiumCapabilitiesView: View {
    @Bindable var model: ArenaModel
    let onCapability: (AtlasArenaCapability) -> Void

    private var capabilities: [AtlasArenaCapability] {
        model.selectedCapabilities?.capabilities ?? []
    }

    private var counts: ArenaCapabilitiesCounts {
        ArenaCapabilitiesJudgment.counts(of: capabilities)
    }

    private var face: ArenaCapabilitiesFace {
        ArenaCapabilitiesJudgment.face(capabilities)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            capabilityHeader
            if face == .empty {
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
        .accessibilityValue(face.productWord)
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
                Text("\(counts.measured)")
                    .font(AtlasFont.serif(56))
                Text("/\(counts.total)")
                    .font(AtlasFont.serif(29))
                Text(ArenaCapabilitiesJudgment.coveredLabel)
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .padding(.leading, 6)
            }
            .foregroundStyle(AtlasTheme.textPrimary)
            .accessibilityLabel(
                "\(counts.measured) de \(counts.total) \(ArenaCapabilitiesJudgment.coveredLabel), medido com confiança"
            )
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
                summaryMetric(counts.improved, "melhoraram", .positive)
                summaryMetric(counts.stable, "estáveis", .neutral)
                summaryMetric(counts.regressed, "regrediram", .negative)
            }
            VStack(alignment: .leading, spacing: 10) {
                summaryMetric(counts.improved, "melhoraram", .positive)
                summaryMetric(counts.stable, "estáveis", .neutral)
                summaryMetric(counts.regressed, "regrediram", .negative)
            }
        }
    }

    private var rows: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let area = model.selectedCapabilities?.areaLabelPt, !area.isEmpty {
                Text(area.uppercased())
                    .font(AtlasFont.mono(10, .medium))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .padding(.bottom, 10)
            }
            ForEach(ArenaCapabilitiesJudgment.groupOrder, id: \.self) { groupKey in
                let members = ArenaCapabilitiesJudgment.members(
                    in: groupKey,
                    capabilities: capabilities
                )
                if !members.isEmpty {
                    Text(model.selectedCapabilities?.groupsPt?[groupKey] ?? groupKey)
                        .font(AtlasFont.serif(17))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .padding(.top, 14)
                        .padding(.bottom, 4)
                    groupRows(members)
                }
            }
            Text(
                ArenaCapabilitiesJudgment.capabilitiesCaption(
                    engineOptionCount: model.capabilityEngineOptions.count
                )
            )
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
                            if let caption = ArenaCapabilitiesJudgment.shortConfidence(capability) {
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
                .accessibilityLabel(ArenaCapabilitiesJudgment.spokenRow(capability))
                .accessibilityIdentifier(A11yID.arenaCapabilityRow(capability.capability))
                ArenaPremiumHairline()
            }
        }
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: 16) {
            ArenaPremiumEmptyGlyph(symbol: "shield.lefthalf.filled")
            Text(ArenaCapabilitiesJudgment.emptyTitle)
                .font(AtlasFont.serif(29))
                .foregroundStyle(AtlasTheme.textPrimary)
            Text(ArenaCapabilitiesJudgment.emptyBody)
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
        .accessibilityLabel(face.spokenFace)
    }

    private func summaryMetric(_ value: Int, _ label: String, _ tone: ArenaPremiumTone) -> some View {
        HStack(spacing: 6) {
            Text("\(value)").font(AtlasFont.serif(25)).foregroundStyle(tone.color)
            Text(label).font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textSecondary)
        }
    }

    private func deltaLabel(_ capability: AtlasArenaCapability) -> some View {
        Text(ArenaCapabilitiesJudgment.deltaDisplayText(capability))
            .font(AtlasFont.mono(10, .medium))
            .foregroundStyle(ArenaCapabilitiesJudgment.deltaColor(capability))
            .frame(width: 44, alignment: .trailing)
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
