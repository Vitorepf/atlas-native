import SwiftUI
import AtlasCore
import Charts

// GOD-RESTRUCTURE: Arena tab surfaces fused (fleet/alerts/results/capabilities)

// MARK: - ArenaPremiumFleetView

struct ArenaPremiumFleetView: View {
    @Bindable var model: ArenaModel

    /// WAVE-157: rank/best from ArenaFleetJudgment (pack ≡ UI).
    private var engines: [AtlasArenaCompositeEngine] {
        ArenaFleetJudgment.rank(model.composite?.engines ?? [])
    }

    private var best: AtlasArenaCompositeEngine? {
        ArenaFleetJudgment.best(in: engines)
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
                text: ArenaScoreJudgment.productFleetKicker(engineCount: engines.count)
            )
            Text(ArenaNowJudgment.productWhereAtlasRises)
                .font(AtlasFont.serif(32))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
            if let best, let mult = best.atlasMultiplier {
                Text(ArenaNowJudgment.productBestGain(engine: ArenaDisplay.engine(best.engine), mult: ArenaFormat.multiplier(mult)))
                    .font(AtlasFont.serifItalic(15))
                    .foregroundStyle(AtlasTheme.accent)
            }
        }
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: 14) {
            ArenaPremiumEmptyGlyph(symbol: "gauge.with.dots.needle.33percent")
            Text(ArenaNowJudgment.productNoEngineMeasured)
                .font(AtlasFont.serif(28))
                .foregroundStyle(AtlasTheme.textPrimary)
            Text(ArenaNowJudgment.productNoEngineMeasuredBody)
                .font(AtlasFont.serifItalic(15))
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
                // "sem" sozinho não diz sem o quê; o par canônico já existe.
                bar(label: ArenaNowJudgment.productWithoutAtlas, value: without, ceiling: maxScore, atlas: false)
                bar(label: ArenaNowJudgment.productWithAtlas, value: withAtlas, ceiling: maxScore, atlas: true)
            } else {
                Text(ArenaScoreJudgment.productUnmeasured)
                    .font(AtlasFont.mono(10))
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
                .font(AtlasFont.mono(10, .medium))
                .foregroundStyle(mult >= 1 ? AtlasTheme.accent : AtlasTheme.alert)
        } else if engine.composite == nil {
            Text(ArenaScoreJudgment.productUnmeasured)
                .font(AtlasFont.mono(10))
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
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 36, alignment: .trailing)
        }
        .accessibilityHidden(true)
    }

    private func fleetSpoken(_ engine: AtlasArenaCompositeEngine) -> String {
        ArenaScoreJudgment.spokenEngine(engine)
    }
}
// MARK: - ArenaPremiumAlertsView

struct ArenaPremiumAlertsView: View {
    @Bindable var model: ArenaModel
    let onSuite: (AtlasArenaSuite) -> Void

    private var reportAlertSuites: Set<String> {
        Set(reportAlerts.map(\.suite))
    }

    private var regressions: [AtlasArenaSuite] {
        model.scoreboard?.suites.filter {
            $0.hasRegression && !reportAlertSuites.contains($0.suite)
        } ?? []
    }

    private var reportAlerts: [AtlasArenaReportSuite] {
        model.report?.attentionSuites ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            let kicker = ArenaScoreJudgment.alertsKicker(hasAlerts: hasAlerts)
            ArenaPremiumKicker(text: kicker.text, tone: kicker.tone)
            .accessibilityIdentifier(A11yID.arenaPremiumAlerts)
            HStack(alignment: .lastTextBaseline, spacing: 7) {
                Text("\(regressions.count + reportAlerts.count)")
                    .font(AtlasFont.serif(58))
                    .foregroundStyle(hasAlerts ? AtlasTheme.alert : AtlasTheme.textPrimary)
                Text(ArenaNowJudgment.productAlertsLower)
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
            alertRows
            blockers
        }
    }

    private var alertRows: some View {
        VStack(spacing: 0) {
            ArenaPremiumHairline()
            ForEach(regressions) { suite in
                Button { onSuite(suite) } label: {
                    alertRow(
                        title: ArenaDisplay.suite(suite.suite),
                        detail: regressionDetail(suite),
                        symbol: "arrow.down.right"
                    )
                }
                .buttonStyle(.plain)
                ArenaPremiumHairline()
            }
            ForEach(reportAlerts) { report in
                alertRow(
                    title: ArenaDisplay.suite(report.suite),
                    detail: report.status.displayPT,
                    symbol: "exclamationmark.triangle"
                )
                ArenaPremiumHairline()
            }
            if !hasAlerts {
                HStack(spacing: 10) {
                    ArenaPremiumIcon(
                        symbol: ArenaPremiumIconography.coverage,
                        tone: .positive
                    )
                    Text(ArenaNowJudgment.productNoRegression)
                }
                    .font(AtlasFont.serifItalic(15))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .frame(maxWidth: .infinity, minHeight: 86, alignment: .leading)
            }
        }
    }

    @ViewBuilder
    private var blockers: some View {
        if let blockers = model.report?.claimBlockers, !blockers.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                ArenaPremiumKicker(text: ArenaNowJudgment.productPublicationBlocked)
                ForEach(blockers, id: \.self) { blocker in
                    HStack(spacing: 8) {
                        ArenaPremiumIcon(
                            symbol: ArenaPremiumIconography.blocked,
                            tone: .neutral,
                            role: .compact
                        )
                        Text(publicBlocker(blocker))
                    }
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textSecondary)
                }
            }
        }
    }

    private var hasAlerts: Bool { !regressions.isEmpty || !reportAlerts.isEmpty }

    private func alertRow(title: String, detail: String, symbol: String) -> some View {
        HStack(spacing: 14) {
            ArenaPremiumIcon(symbol: symbol, tone: .negative)
            Text(title)
                .atlasSans(15, .medium)
                .foregroundStyle(AtlasTheme.textPrimary)
            Spacer()
            Text(detail)
                .font(AtlasFont.mono(10, .medium))
                .foregroundStyle(AtlasTheme.alert)
                .multilineTextAlignment(.trailing)
            ArenaPremiumChevron()
        }
        .frame(minHeight: 58)
        .contentShape(Rectangle())
    }

    private func regressionDetail(_ suite: AtlasArenaSuite) -> String {
        let delta = suite.engines.first(where: \.regressed)?.delta
        return ArenaScoreJudgment.regressionDetail(delta: delta)
    }

    private func publicBlocker(_ raw: String) -> String {
        switch raw {
        case "missing_data": "há dados incompletos"
        case "pipeline_invalid": "a validação do pipeline falhou"
        case "suite_failed": "uma suíte não concluiu"
        default: "resultado ainda não pode ser afirmado"
        }
    }
}
// MARK: - ArenaPremiumResultsView

struct ArenaPremiumResultsView: View {
    @Bindable var model: ArenaModel
    let reduceMotion: Bool
    let onSuite: (AtlasArenaSuite) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            if let engine = model.arenaPrimaryEngine {
                resultHeader(engine)
                resultMetrics(engine)
                if !engine.history.isEmpty {
                    ArenaPremiumKicker(text: ArenaNowJudgment.productIndexByRound)
                    ArenaCompositeChart(engine: engine, reduceMotion: reduceMotion)
                        .frame(height: 190)
                }
                suiteList
            } else {
                empty
            }
        }
    }

    private var measuredEngineOptions: [String] {
        model.composite?.engines.map(\.engine) ?? []
    }

    private func resultHeader(_ engine: AtlasArenaCompositeEngine) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ArenaPremiumKicker(
                text: ArenaScoreJudgment.productResultsKicker(claimAllowed: model.report?.claimAllowed)
            )
            .accessibilityIdentifier(A11yID.arenaPremiumResults)
            ArenaPremiumEngineTitle(
                engineID: engine.engine,
                options: measuredEngineOptions,
                onSelect: { model.capabilitiesEngineSelection = $0 }
            )
            if let narrative = model.report?.narrative {
                Text(narrative)
                    .font(AtlasFont.serifItalic(15))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func resultMetrics(_ engine: AtlasArenaCompositeEngine) -> some View {
        let atlasDelta = ArenaScoreJudgment.pairedDelta(engine: engine)
        let judgment = ArenaScoreJudgment.state(
            engine: engine,
            claimAllowed: model.report?.claimAllowed
        )
        return VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .lastTextBaseline) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(ArenaNowJudgment.productIndex).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textTertiary)
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text(ArenaFormat.score(engine.composite))
                            .font(AtlasFont.serif(62))
                        Text("/10")
                            .font(AtlasFont.mono(12, .medium))
                            .foregroundStyle(AtlasTheme.textSecondary)
                    }
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(ArenaScoreJudgment.spokenScore(engine.composite))
                }
                Spacer()
                // Δ só com par publicado (WAVE-021 — never fabricate 0).
                if let atlasDelta, judgment == .published || judgment == .partial || judgment == .regressed {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(ArenaFormat.signed(atlasDelta))
                            .font(AtlasFont.serifItalic(18))
                            .foregroundStyle(atlasDelta >= 0 ? AtlasTheme.accent : AtlasTheme.alert)
                        Text(ArenaNowJudgment.productVsWithoutAtlas)
                            .font(AtlasFont.mono(10))
                            .foregroundStyle(AtlasTheme.textSecondary)
                    }
                }
            }
            ArenaPremiumHairline()
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 28) {
                    smallMetric("Sem Atlas", ArenaFormat.score(engine.withoutAtlasComposite))
                    smallMetric("Com Atlas", ArenaFormat.score(engine.withAtlasComposite), tone: .active)
                    smallMetric("Multiplicador", ArenaFormat.multiplier(engine.atlasMultiplier), tone: .active)
                }
                VStack(alignment: .leading, spacing: 12) {
                    smallMetric("Sem Atlas", ArenaFormat.score(engine.withoutAtlasComposite))
                    smallMetric("Com Atlas", ArenaFormat.score(engine.withAtlasComposite), tone: .active)
                    smallMetric("Multiplicador", ArenaFormat.multiplier(engine.atlasMultiplier), tone: .active)
                }
            }
            Text(ArenaNowJudgment.productCoverageLine(coverage: model.arenaCoverageText, judgment: judgment.rawValue, scale: ArenaScoreJudgment.productScaleCaption))
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
    }

    private var suiteList: some View {
        VStack(alignment: .leading, spacing: 0) {
            ArenaPremiumKicker(text: ArenaNowJudgment.productBySuite)
                .padding(.bottom, 8)
            ForEach(model.scoreboard?.suites ?? []) { suite in
                Button { onSuite(suite) } label: {
                    HStack(spacing: 13) {
                        ArenaPremiumIcon(
                            symbol: ArenaPremiumIconography.suite(suite.suite),
                            tone: suite.hasRegression ? .negative : .neutral
                        )
                        Text(ArenaDisplay.suite(suite.suite))
                            .font(AtlasFont.serif(17))
                            .foregroundStyle(AtlasTheme.textPrimary)
                        Spacer()
                        suiteMetric(suite)
                        ArenaPremiumChevron()
                    }
                    .frame(minHeight: 54)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier(A11yID.arenaPremiumResultSuite(suite.suite))
                ArenaPremiumHairline()
            }
            Text(ArenaScoreJudgment.absenceNeverZero)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .padding(.top, 16)
        }
    }

    @ViewBuilder
    private func suiteMetric(_ suite: AtlasArenaSuite) -> some View {
        if let engine = suite.engines.first(where: { $0.engine == model.arenaSelectedEngineID })
            ?? suite.engines.first {
            HStack(spacing: 6) {
                Text(ArenaFormat.score(engine.score))
                    .foregroundStyle(AtlasTheme.textPrimary)
                if let delta = engine.delta {
                    Text(ArenaFormat.signed(delta))
                        .foregroundStyle(delta < 0 ? AtlasTheme.alert : (delta > 0 ? AtlasTheme.textPrimary : AtlasTheme.textSecondary))
                }
            }
            .font(AtlasFont.mono(10, .medium))
        } else {
            Text(ArenaScoreJudgment.productUnmeasured)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
        }
    }

    private func smallMetric(
        _ label: String,
        _ value: String,
        tone: ArenaPremiumTone = .neutral
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textSecondary)
            Text(value).font(AtlasFont.mono(18, .medium)).foregroundStyle(tone.color)
        }
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: 18) {
            ArenaPremiumEmptyGlyph(symbol: "chart.xyaxis.line")
            Text(ArenaNowJudgment.productNoResultMeasured)
                .font(AtlasFont.serif(32))
                .foregroundStyle(AtlasTheme.textPrimary)
            Text(ArenaNowJudgment.productNoResultBody)
                .font(AtlasFont.serifItalic(16))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
    }
}
// MARK: - ArenaPremiumCapabilitiesView

// MARK: - Capabilities surface
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

    // MARK: Sections
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
                Text(ArenaNowJudgment.productSlashTotal(counts.total))
                    .font(AtlasFont.serif(28))
                Text(ArenaCapabilitiesJudgment.productCovered)
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .padding(.leading, 6)
            }
            .foregroundStyle(AtlasTheme.textPrimary)
            .accessibilityLabel(
                "\(counts.measured) de \(counts.total) \(ArenaCapabilitiesJudgment.productCovered), medido com confiança"
            )
        }
    }

    private var trackLegend: some View {
        HStack(spacing: 16) {
            HStack(spacing: 6) {
                Circle()
                    .stroke(AtlasTheme.textSecondary, lineWidth: 1.5)
                    .frame(width: 8, height: 8)
                Text(ArenaNowJudgment.productWithoutAtlas)
            }
            HStack(spacing: 5) {
                Text("✦")
                    .font(AtlasFont.serif(12))
                    .foregroundStyle(AtlasTheme.accent)
                Text(ArenaNowJudgment.productWithAtlas)
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
                ArenaCapabilitiesJudgment.productCapabilitiesCaption(
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
                            // Esta linha é a ressalva que DESQUALIFICA o número
                            // ao lado ("baixa confiança", "não medível").
                            // Cortada em uma linha, sobrava "70% descartado no
                            // setup · não…" — o operador lia o delta e perdia
                            // exatamente o aviso de que ele não vale.
                            if let caption = ArenaCapabilitiesJudgment.productShortConfidence(capability) {
                                Text(caption)
                                    .font(AtlasFont.mono(9))
                                    .foregroundStyle(AtlasTheme.textTertiary)
                                    .fixedSize(horizontal: false, vertical: true)
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

    // MARK: Empty / metrics
    private var empty: some View {
        VStack(alignment: .leading, spacing: 16) {
            ArenaPremiumEmptyGlyph(symbol: "shield.lefthalf.filled")
            Text(ArenaCapabilitiesJudgment.productEmptyTitle)
                .font(AtlasFont.serif(28))
                .foregroundStyle(AtlasTheme.textPrimary)
            Text(ArenaCapabilitiesJudgment.productEmptyBody)
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
        .accessibilityLabel(face.spokenFace)
    }

    private func summaryMetric(_ value: Int, _ label: String, _ tone: ArenaPremiumTone) -> some View {
        HStack(spacing: 6) {
            Text("\(value)").font(AtlasFont.serif(24)).foregroundStyle(tone.color)
            Text(label).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textSecondary)
        }
    }

    private func deltaLabel(_ capability: AtlasArenaCapability) -> some View {
        Text(ArenaCapabilitiesJudgment.deltaDisplayText(capability))
            .font(AtlasFont.mono(10, .medium))
            .foregroundStyle(ArenaCapabilitiesJudgment.deltaColor(capability))
            .frame(width: 44, alignment: .trailing)
    }
}

// MARK: - Track row
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
                        .font(AtlasFont.serif(14))
                        .foregroundStyle(AtlasTheme.accent)
                        .offset(x: max(0, min(w - 13, w * withAtlas - 6.5)))
                }
            }
        }
        .frame(height: 18)
        .accessibilityHidden(true)
    }
}
// MARK: - ArenaPremiumCapabilityDetail

struct ArenaPremiumCapabilityDetail: View {
    @Environment(\.dismiss) private var dismiss
    let capability: AtlasArenaCapability
    let scoreboard: AtlasArenaScoreboard?
    let engineId: String?

    private var delta: Double? {
        guard let baseline = capability.score, let withAtlas = capability.withAtlas else { return nil }
        return withAtlas - baseline
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
            ArenaPremiumKicker(text: ArenaNowJudgment.productMeasuredCapabilityScale)
                        .accessibilityIdentifier(A11yID.arenaPremiumCapabilityDetail)
                    Text(capability.labelPt)
                        .font(AtlasFont.serif(34))
                        .foregroundStyle(AtlasTheme.textPrimary)
                    comparison
                    contribution
                    provenance
                }
                .padding(AtlasTheme.Space.screen)
            }
            .scrollIndicators(.hidden)
            .background(AtlasTheme.bg.ignoresSafeArea())
            .navigationTitle(ArenaCapabilitiesJudgment.productTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    AtlasCloseToolbarButton(
                        spokenLabel: ArenaCapabilitiesJudgment.spokenClose,
                        spokenHint: ArenaCapabilitiesJudgment.spokenCloseHint,
                        reduceMotion: UIAccessibility.isReduceMotionEnabled
                    ) { dismiss() }
                }
            }
        }
    }

    private var comparison: some View {
        VStack(alignment: .leading, spacing: 18) {
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 30) {
                    metric("Sem Atlas", capability.score)
                    ArenaPremiumIcon(
                        symbol: ArenaPremiumIconography.comparison,
                        tone: .muted,
                        role: .compact
                    )
                    metric("Com Atlas", capability.withAtlas, tone: .active)
                    Spacer()
                    Text(ArenaFormat.signed(delta))
                        .font(AtlasFont.mono(16, .medium))
                        .foregroundStyle(deltaColor)
                }
                VStack(alignment: .leading, spacing: 14) {
                    metric("Sem Atlas", capability.score)
                    metric("Com Atlas", capability.withAtlas, tone: .active)
                    Text(ArenaNowJudgment.productDeltaLine(ArenaFormat.signed(delta)))
                        .font(AtlasFont.mono(12, .medium))
                        .foregroundStyle(deltaColor)
                }
            }
            ArenaCapabilityTrack(baseline: capability.score, withAtlas: capability.withAtlas)
                .frame(height: 24)
        }
    }

    private var contribution: some View {
        VStack(alignment: .leading, spacing: 0) {
            ArenaPremiumKicker(text: ArenaNowJudgment.productContributingSuites)
                .padding(.bottom, 10)
            ArenaPremiumHairline()
            ForEach(capability.suitesContributing, id: \.self) { suite in
                HStack {
                    ArenaPremiumIcon(
                        symbol: ArenaPremiumIconography.suite(suite)
                    )
                    Text(ArenaDisplay.suite(suite))
                        .atlasSans(15, .medium)
                        .foregroundStyle(AtlasTheme.textPrimary)
                    Spacer()
                    Text(suiteCases(suite))
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textSecondary)
                }
                .padding(.vertical, 14)
                ArenaPremiumHairline()
            }
        }
    }

    private var provenance: some View {
        VStack(alignment: .leading, spacing: 8) {
            ArenaPremiumKicker(text: ArenaNowJudgment.productProvenance)
            // "denominador" é jargão de estatístico — português direto.
            Text("\(capability.casesTotal.map(String.init) ?? "—") casos somados na conta publicada")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textSecondary)
            Text(ArenaNowJudgment.productArmAbsenceHonesty)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
        }
    }

    private var deltaColor: Color {
        guard let delta else { return AtlasTheme.textTertiary }
        if abs(delta) <= 0.005 { return AtlasTheme.textSecondary }
        return delta > 0 ? AtlasTheme.textPrimary : AtlasTheme.alert
    }

    private func metric(_ label: String, _ value: Double?, tone: ArenaPremiumTone = .neutral) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(ArenaFormat.score(value))
                .font(AtlasFont.serif(34))
                .foregroundStyle(tone.color)
            Text(label)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
    }

    private func suiteCases(_ suite: String) -> String {
        guard let engines = scoreboard?.suites.first(where: { $0.suite == suite })?.engines,
              let total = (engines.first(where: { $0.engine == engineId }) ?? engines.first)?
                .casesTotal else { return "casos não publicados" }
        return "\(total) casos"
    }
}
// MARK: - ArenaPremiumComparison

struct ArenaPremiumComparison: View {
    @Bindable var model: ArenaModel
    let provisional: Bool

    /// Par publicado: suíte da corrida → qualquer suíte do motor → composto.
    private var pair: PublishedPair? {
        if let suiteEngine = suiteEnginePair,
           let without = suiteEngine.withoutAtlasScore,
           let withAtlas = suiteEngine.withAtlasScore {
            return PublishedPair(
                without: without,
                withAtlas: withAtlas,
                source: .suite
            )
        }
        if let engine = model.arenaPrimaryEngine,
           let without = engine.withoutAtlasComposite,
           let withAtlas = engine.withAtlasComposite {
            return PublishedPair(without: without, withAtlas: withAtlas, source: .composite)
        }
        return nil
    }

    private var suiteEnginePair: AtlasArenaSuiteEngine? {
        let engineID = resolvedEngineID
        let suites = model.scoreboard?.suites ?? []
        if let run = model.arenaPrimaryRun {
            if let match = suites.first(where: { $0.suite == run.suite })?
                .engines.first(where: { engineMatches($0.engine, engineID) }),
               match.withoutAtlasScore != nil,
               match.withAtlasScore != nil {
                return match
            }
        }
        // Último par publicado do mesmo motor (suíte da corrida pode ainda
        // não ter scoreboard — a medição ao vivo não apaga o histórico).
        return suites
            .flatMap(\.engines)
            .first {
                engineMatches($0.engine, engineID)
                    && $0.withoutAtlasScore != nil
                    && $0.withAtlasScore != nil
            }
    }

    private var resolvedEngineID: String? {
        if let engine = model.arenaPrimaryRun?.engine, !engine.isEmpty { return engine }
        return model.preferredEngine ?? model.arenaPrimaryEngine?.engine
    }

    var body: some View {
        Group {
            if let pair {
                VStack(alignment: .leading, spacing: 12) {
                    ArenaPremiumHairline()
                    ArenaPremiumKicker(text: kickerTitle(for: pair))
                    values(pair)
                }
            }
            // Sem par publicado: some a seção inteira — kicker órfão era mentira
            // visual (título sem 6,0 → 7,6).
        }
    }

    private func kickerTitle(for pair: PublishedPair) -> String {
        // WAVE-021: Comparison silence law is the global kicker grammar.
        ArenaScoreJudgment.comparisonKicker(
            provisional: provisional,
            sourceSuite: pair.source == .suite
        )
    }

    private func values(_ pair: PublishedPair) -> some View {
        let delta = pair.withAtlas - pair.without
        return HStack(alignment: .lastTextBaseline, spacing: 14) {
            metric(ArenaFormat.score(pair.without), "Sem Atlas", gold: false)
            Text("→")
                .font(AtlasFont.serif(15))
                .foregroundStyle(AtlasTheme.textTertiary)
                .padding(.bottom, 2)
            metric(ArenaFormat.score(pair.withAtlas), "Com Atlas", gold: true)
            Spacer(minLength: 4)
            Text(ArenaFormat.signed(delta))
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(
                    abs(delta) < 0.005
                        ? AtlasTheme.textSecondary
                        : (delta > 0 ? AtlasTheme.accent : AtlasTheme.alert)
                )
                .padding(.bottom, 2)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            ArenaScoreJudgment.spokenPair(without: pair.without, withAtlas: pair.withAtlas)
        )
    }

    private func metric(_ value: String, _ label: String, gold: Bool) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label.uppercased())
                .font(AtlasFont.mono(9))
                .tracking(1.2)
                .foregroundStyle(AtlasTheme.textTertiary)
            Text(value)
                .font(AtlasFont.serif(28))
                .foregroundStyle(gold ? AtlasTheme.accent : AtlasTheme.textPrimary)
        }
    }

    private func engineMatches(_ candidate: String, _ expected: String?) -> Bool {
        guard let expected, !expected.isEmpty else { return true }
        return candidate == expected
    }

    private struct PublishedPair {
        enum Source { case suite, composite }
        let without: Double
        let withAtlas: Double
        let source: Source
    }
}

// MARK: - ArenaPremiumStopSheet

struct ArenaPremiumStopSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Bindable var model: ArenaModel
    let run: AtlasArenaLiveRun
    @State private var actor = ""
    @State private var reason = ""

    private var stopFace: ArenaStopFace {
        ArenaStopJudgment.face(actor: actor, reason: reason)
    }

    private var valid: Bool {
        ArenaStopJudgment.canSubmit(actor: actor, reason: reason)
    }

    private var isConfirmed: Bool {
        model.lastStopReceipt?.measurementIdPublic == run.measurementIdPublic
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    ArenaPremiumEmptyGlyph(symbol: "stop.circle", tone: .negative)
                    ArenaPremiumKicker(text: ArenaStopJudgment.productKicker, tone: .negative)
                        .accessibilityIdentifier(A11yID.arenaPremiumStopSheet)
                    Text(ArenaStopJudgment.productHeroTitle)
                        .font(AtlasFont.serif(34))
                        .foregroundStyle(AtlasTheme.textPrimary)
                    Text(ArenaStopJudgment.bodyCopy)
                        .font(.system(.body))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                    fields
                    receipt
                    confirm
                }
                .padding(AtlasTheme.Space.screen)
            }
            .scrollIndicators(.hidden)
            .background(AtlasTheme.bg.ignoresSafeArea())
            .navigationTitle(ArenaStopJudgment.productNavigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    AtlasCloseToolbarButton(
                        spokenLabel: ArenaStopJudgment.spokenClose,
                        spokenHint: ArenaStopJudgment.spokenCloseHint,
                        reduceMotion: reduceMotion
                    ) { dismiss() }
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityLabel(
                ArenaStopJudgment.spokenSheet(
                    actor: actor,
                    reason: reason,
                    suite: ArenaDisplay.suite(run.suite)
                )
            )
            .accessibilityValue(stopFace.productWord)
        }
        .onAppear { model.controlError = nil }
    }

    private var fields: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Chrome da casa: .roundedBorder rendia caixas BRANCAS no dark
            // (a mesma quebra já corrigida na folha de rodar) — ink neutro.
            fieldLabel(ArenaStopJudgment.productActor)
            TextField(ArenaStopJudgment.productActorPlaceholder, text: $actor)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .modifier(ArenaFieldChrome())
                .accessibilityIdentifier(A11yID.arenaPremiumStopActor)
            fieldLabel(ArenaStopJudgment.productReason)
            TextField(ArenaStopJudgment.productReasonPlaceholder, text: $reason, axis: .vertical)
                .lineLimit(2...4)
                .modifier(ArenaFieldChrome())
                .accessibilityIdentifier(A11yID.arenaPremiumStopReason)
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .atlasSans(12, .medium)
            .foregroundStyle(AtlasTheme.textSecondary)
    }

    @ViewBuilder
    private var receipt: some View {
        if let value = model.lastStopReceipt,
           value.measurementIdPublic == run.measurementIdPublic {
            VStack(alignment: .leading, spacing: 6) {
                Label(
                    value.accepted ? "Solicitação confirmada" : "Medição já havia terminado",
                    systemImage: value.accepted ? "checkmark.seal" : "info.circle"
                )
                    .font(.system(.callout, weight: .semibold))
                    .foregroundStyle(value.accepted ? AtlasTheme.textPrimary : AtlasTheme.textSecondary)
                Text(value.stopsAfterCurrentCase ? "parada após o caso atual" : value.status.rawValue)
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
            .accessibilityIdentifier(A11yID.arenaPremiumStopReceipt)
            .accessibilityLabel(ArenaStopJudgment.spokenReceipt(value))
        }
        if let error = model.controlError {
            Text(error)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.alert)
        }
    }

    private var confirm: some View {
        Button {
            guard let measurementId = run.measurementIdPublic else { return }
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            Task {
                await model.stopMeasurement(
                    measurementId: measurementId,
                    operatorActor: actor,
                    operatorReason: reason
                )
            }
        } label: {
            HStack(spacing: 9) {
                ArenaPremiumIcon(
                    symbol: ArenaPremiumIconography.stop,
                    tone: valid && !isConfirmed ? .negative : .muted
                )
                Text(model.isStoppingMeasurement ? ArenaStopJudgment.productRequesting : ArenaStopJudgment.productConfirm)
            }
                .font(.system(.body, weight: .semibold))
                .frame(maxWidth: .infinity, minHeight: 50)
                .foregroundStyle(valid && !isConfirmed ? AtlasTheme.alert : AtlasTheme.textTertiary)
                .background(Capsule().fill(AtlasTheme.alert.opacity(valid && !isConfirmed ? 0.08 : 0.03)))
                .overlay(Capsule().stroke(AtlasTheme.alert.opacity(valid && !isConfirmed ? 0.5 : 0.15), lineWidth: 1))
        }
        .buttonStyle(PressableScale())
        .disabled(!valid || model.isStoppingMeasurement || isConfirmed)
        .accessibilityIdentifier(A11yID.arenaPremiumStopConfirm)
        .accessibilityLabel(ArenaStopJudgment.spokenConfirm(actor: actor, reason: reason))
        .accessibilityHint(ArenaStopJudgment.spokenConfirmHint)
    }
}

// MARK: - ArenaPremiumPlanQueueViews

// MARK: - Plan view
struct ArenaPremiumPlanView: View {
    @Bindable var model: ArenaModel

    /// WAVE-085: live ∪ queue merge from Judgment.
    private var liveRuns: [AtlasArenaLiveRun] {
        ArenaPlanQueueJudgment.mergedLiveRuns(
            measurementRuns: model.arenaPrimaryMeasurementRuns,
            queuedRuns: model.livePresentation?.queuedRuns ?? []
        )
    }

    private var liveSuites: [String] {
        ArenaPlanQueueJudgment.liveSuites(from: liveRuns)
    }

    private var planFace: ArenaPlanFace {
        ArenaPlanQueueJudgment.planFace(
            activePlan: model.activePlan,
            liveSuites: liveSuites
        )
    }

    private var liveArmsText: String {
        var seen = Set<String>()
        return liveRuns.compactMap(\.arm)
            .compactMap { seen.insert($0.rawValue).inserted ? $0.labelPT : nil }
            .joined(separator: " → ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            ArenaPremiumKicker(text: ArenaNowJudgment.productMeasureOrder)
                .accessibilityIdentifier(A11yID.arenaPremiumPlan)
            Text(ArenaNowJudgment.productPlan)
                .font(AtlasFont.serif(36))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityValue(planFace.productWord)
            switch planFace {
            case .published:
                if let plan = model.activePlan {
                    headline(
                        engines: plan.engines.count,
                        suites: plan.suites.count,
                        arms: plan.arms.count,
                        runs: plan.runsPlanned
                    )
                    suiteSequence(
                        plan.suites,
                        armsText: plan.arms.map(\.labelPT).joined(separator: " → "),
                        footer: planFace.footer
                    )
                }
            case .derivedLive:
                headline(
                    engines: Set(liveRuns.map(\.engineDisplayName)).count,
                    suites: liveSuites.count,
                    arms: Set(liveRuns.compactMap { $0.arm?.rawValue }).count,
                    runs: liveRuns.count
                )
                suiteSequence(
                    liveSuites,
                    armsText: liveArmsText,
                    footer: planFace.footer
                )
            case .empty:
                empty
            }
        }
    }

    // MARK: Plan sections
    private func headline(engines: Int, suites: Int, arms: Int, runs: Int) -> some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 28) {
                metric(engines, "motores")
                metric(suites, "suítes")
                metric(arms, "braços")
                metric(runs, "corridas")
            }
            VStack(alignment: .leading, spacing: 12) {
                metric(engines, "motores")
                metric(suites, "suítes")
                metric(runs, "corridas")
            }
        }
    }

    private func suiteSequence(_ suites: [String], armsText: String, footer: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            ArenaPremiumHairline()
            ForEach(Array(suites.enumerated()), id: \.element) { index, suite in
                let status = ArenaPlanQueueJudgment.suiteStatus(
                    suite: suite,
                    measurementRuns: model.arenaPrimaryMeasurementRuns
                )
                HStack(spacing: 14) {
                    Text(String(format: "%02d", index + 1))
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .frame(width: 28, alignment: .leading)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(ArenaDisplay.suite(suite))
                            .atlasSans(15, .medium)
                            .foregroundStyle(AtlasTheme.textPrimary)
                        Text(armsText)
                            .font(AtlasFont.mono(10))
                            .foregroundStyle(AtlasTheme.textSecondary)
                    }
                    Spacer()
                    ArenaPremiumIcon(
                        symbol: ArenaPremiumIconography.planStatus(status),
                        tone: ArenaPlanQueueJudgment.suiteTone(status)
                    )
                }
                .padding(.vertical, 14)
                .accessibilityIdentifier(A11yID.arenaPremiumPlanRow(suite))
                ArenaPremiumHairline()
            }
            Text(footer)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .padding(.top, 16)
        }
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: 16) {
            ArenaPremiumEmptyGlyph(symbol: "list.bullet.rectangle")
            Text(ArenaNowJudgment.productNoPlanActive)
                .font(AtlasFont.serif(28))
                .foregroundStyle(AtlasTheme.textPrimary)
            Text(ArenaPlanFace.empty.footer)
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
        .accessibilityValue(ArenaPlanFace.empty.productWord)
    }

    private func metric(_ value: Int, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("\(value)").font(AtlasFont.serif(30)).foregroundStyle(AtlasTheme.textPrimary)
            Text(label).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textSecondary)
        }
    }
}

// MARK: - Queue view
struct ArenaPremiumQueueView: View {
    @Bindable var model: ArenaModel

    private var queued: [AtlasArenaLiveRun] {
        model.livePresentation?.queuedRuns ?? []
    }

    private var queuedSuites: [String] {
        ArenaPlanQueueJudgment.liveSuites(from: queued)
    }

    private var queueFace: ArenaQueueFace {
        ArenaPlanQueueJudgment.queueFace(queuedSuiteCount: queuedSuites.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            ArenaPremiumKicker(
                text: "Aguardando execução",
                tone: queueFace.productWord == "empty" ? .neutral : .active,
                showsLiveMark: queueFace.productWord != "empty"
            )
            .accessibilityIdentifier(A11yID.arenaPremiumQueue)
            HStack(alignment: .lastTextBaseline) {
                Text("\(queuedSuites.count)")
                    .font(AtlasFont.serif(58))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text(queuedSuites.count == 1 ? "suíte na fila" : "suítes na fila")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
            .accessibilityValue(queueFace.productWord)
            .accessibilityLabel(queueFace.spokenFace)
            queueRows
        }
    }

    // MARK: Queue rows
    private var queueRows: some View {
        VStack(spacing: 0) {
            ArenaPremiumHairline()
            ForEach(Array(queuedSuites.enumerated()), id: \.element) { index, suite in
                HStack(spacing: 14) {
                    Text("\(index + 1)")
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .frame(width: 26, alignment: .leading)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(ArenaDisplay.suite(suite))
                            .atlasSans(15, .medium)
                            .foregroundStyle(AtlasTheme.textPrimary)
                        Text(queueDetail(suite))
                            .font(AtlasFont.mono(10))
                            .foregroundStyle(AtlasTheme.textSecondary)
                    }
                    Spacer()
                    ArenaPremiumIcon(symbol: "clock", tone: .muted)
                }
                .padding(.vertical, 14)
                .accessibilityIdentifier(A11yID.arenaPremiumQueueRow(suite))
                ArenaPremiumHairline()
            }
            if case .empty = queueFace {
                Text(ArenaRunSheetJudgment.productEmptyQueue)
                    .font(AtlasFont.serifItalic(15))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .frame(maxWidth: .infinity, minHeight: 90, alignment: .leading)
                    .accessibilityValue(ArenaQueueFace.empty.productWord)
            }
        }
    }

    private func queueDetail(_ suite: String) -> String {
        let runs = queued.filter { $0.suite == suite }
        var seenArms = Set<String>()
        let arms = runs.compactMap(\.arm)
            .compactMap { seenArms.insert($0.rawValue).inserted ? $0.labelPT : nil }
        let engine = runs.first.map { ArenaDisplay.engine($0.engineDisplayName) }
        return ([engine] + arms).compactMap(\.self).joined(separator: " · ")
    }
}

// MARK: - ArenaRunSheet

// MARK: - Host

extension ArenaRunSheet {
    @ViewBuilder
    var formSections: some View {
        suitesFormSection
        engineFormSection
        formGovernanceSections
    }

    @ViewBuilder
    var suitesFormSection: some View {
        section("Suítes") {
            if installedSuites.isEmpty {
                Text(ArenaRunSheetJudgment.productNoSuiteAdapter)
                    .font(AtlasFont.serifItalic(14))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityIdentifier(A11yID.arenaRunSuitesEmpty)
                    .accessibilityLabel(ArenaRunSheetJudgment.spokenEmptySuites())
            } else {
                ForEach(installedSuites) { suite in
                    toggleRow(
                        title: suite.suite,
                        subtitle: suite.isMeasured ? "\(suite.runsTotal) rodadas" : "não medido",
                        isOn: selectedSuites.contains(suite.suite)
                    ) {
                        if selectedSuites.contains(suite.suite) { selectedSuites.remove(suite.suite) }
                        else { selectedSuites.insert(suite.suite) }
                    }
                    .accessibilityIdentifier("arena-run-suite-\(suite.suite)")
                }
            }
        }
    }

    @ViewBuilder
    var engineFormSection: some View {
        section("Motores") {
            if engines.isEmpty {
                Text(ArenaRunSheetJudgment.productNoPublishedEngine)
                    .font(AtlasFont.serifItalic(14))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityIdentifier(A11yID.arenaRunEnginesEmpty)
                    .accessibilityLabel(ArenaRunSheetJudgment.spokenEmptyEngines())
            } else {
                ForEach(engines, id: \.self) { engine in
                    toggleRow(
                        title: ArenaDisplay.engine(engine),
                        subtitle: nil,
                        isOn: selectedEngines.contains(engine)
                    ) {
                        if selectedEngines.contains(engine) {
                            selectedEngines.remove(engine)
                        } else {
                            selectedEngines.insert(engine)
                        }
                    }
                    .accessibilityIdentifier("arena-run-engine-\(engine)")
                }
                if engines.count > 1 {
                    Text(ArenaNowJudgment.productCompareEnginesHint)
                        .font(.system(.caption))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .accessibilityHidden(true)
                }
            }
        }
    }

    @ViewBuilder
    var formGovernanceSections: some View {
        section("Comparação") {
            ForEach(AtlasArenaRunArm.allCases) { arm in
                toggleRow(title: arm.labelPT, subtitle: armSubtitle(arm), isOn: selectedArms.contains(arm)) {
                    if selectedArms.contains(arm), selectedArms.count > 1 { selectedArms.remove(arm) }
                    else { selectedArms.insert(arm) }
                }
                .accessibilityIdentifier("arena-run-arm-\(arm.rawValue)")
            }
        }

        section("Governança") {
            fieldLabel(ArenaStopJudgment.productActor)
            TextField("quem autoriza esta medição", text: $actor)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .modifier(ArenaFieldChrome())
                .accessibilityIdentifier(A11yID.arenaRunActor)
                .accessibilityHint(ArenaRunSheetJudgment.spokenActorHint)
            fieldLabel(ArenaStopJudgment.productReason)
            TextField("por que rodar agora (fica no recibo)", text: $reason, axis: .vertical)
                .lineLimit(2...4)
                .modifier(ArenaFieldChrome())
                .accessibilityIdentifier(A11yID.arenaRunReason)
                .accessibilityHint(ArenaRunSheetJudgment.spokenReasonHint)
        }
    }

    func armSubtitle(_ arm: AtlasArenaRunArm) -> String {
        switch arm {
        case .baseline: "o motor puro, como referência"
        case .withAtlas: "os mesmos casos, com o Atlas"
        }
    }

    func fieldLabel(_ text: String) -> some View {
        Text(text)
            .atlasSans(12, .medium)
            .foregroundStyle(AtlasTheme.textSecondary)
    }
}

struct ArenaFieldChrome: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(.callout))
            .foregroundStyle(AtlasTheme.textPrimary)
            .padding(.horizontal, 12).padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: AtlasTheme.Radius.control)
                    .fill(AtlasTheme.bgRecessed)
                    .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control)
                        .stroke(AtlasTheme.separator, lineWidth: 1)))
    }
}

extension ArenaRunSheet {
    /// WAVE-055: receipt chrome from ArenaStartJudgment.
    func receiptCard(_ receipt: AtlasArenaStartReceipt) -> some View {
        let face = ArenaStartJudgment.receiptFace(receipt)
        return VStack(alignment: .leading, spacing: 6) {
            Text(ArenaNowJudgment.productReceiptHash(receipt.receiptHash))
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(1)
                .truncationMode(.middle)
                .accessibilityHidden(true)
            Text(ArenaStartJudgment.productReceiptStatusLine(receipt))
                .font(.system(.callout, weight: .semibold))
                .foregroundStyle(
                    face.productWord == "worker_gap"
                        ? AtlasTheme.domOperacional
                        : AtlasTheme.accent
                )
                .accessibilityHidden(true)
            if model.lastStartEnginesCount > 1 {
                Text("\(model.lastStartEnginesCount) motores · \(model.lastStartRunsPlannedTotal) runs na fila")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .monospacedDigit()
                    .accessibilityHidden(true)
            }
            if receipt.workerImplemented == false {
                Text(ArenaStartJudgment.workerGapCopy)
                    .font(.system(.caption))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
        }
        .padding(14)
        .atlasCard()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ArenaStartJudgment.spokenReceipt(receipt, enginesCount: model.lastStartEnginesCount, runsPlannedTotal: model.lastStartRunsPlannedTotal))
        .accessibilityValue(face.productWord)
        .accessibilityIdentifier(A11yID.arenaRunReceipt)
    }
}

// MARK: - Body

// MARK: - Face

extension ArenaRunSheet {
    /// WAVE-074: exclusive run-sheet shell face.
    var runSheetFace: ArenaRunSheetFace {
        ArenaRunSheetJudgment.face(
            engineCount: engines.count,
            suiteCount: installedSuites.count
        )
    }

}

// MARK: - Section · toggle chrome

extension ArenaRunSheet {
    func section<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            ArenaPremiumKicker(text: title)
                .accessibilityAddTraits(.isHeader)
            content()
                .padding(.leading, 2)
        }
    }

    func toggleRow(title: String, subtitle: String?, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                ArenaPremiumIcon(
                    symbol: isOn ? "checkmark.circle" : "circle",
                    tone: isOn ? .active : .muted
                )
                .modifier(ArenaToggleSymbolBounce(enabled: !reduceMotion, isOn: isOn))
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(.callout, weight: .medium))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .accessibilityHidden(true)
                    if let subtitle {
                        Text(subtitle)
                            .font(AtlasFont.mono(10))
                            .foregroundStyle(AtlasTheme.textTertiary)
                            .accessibilityHidden(true)
                    }
                }
                Spacer()
            }
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableScale())
        .accessibilityLabel(toggleAccessibilityLabel(title: title, subtitle: subtitle, isOn: isOn))
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }

    func toggleAccessibilityLabel(title: String, subtitle: String?, isOn: Bool) -> String {
        let state = isOn ? "selecionado" : "não selecionado"
        if let subtitle { return "\(title), \(subtitle), \(state)" }
        return "\(title), \(state)"
    }
}

// MARK: - Host

struct ArenaRunSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Bindable var model: ArenaModel
    @State var selectedSuites: Set<String> = []
    @State var selectedEngines: Set<String> = []
    @State var selectedArms: Set<AtlasArenaRunArm> = [.baseline, .withAtlas]
    @State var actor = ""
    @State var reason = ""

    var body: some View {
        NavigationStack {
            runScrollBody
        }
        .onAppear { seedDefaultsIfNeeded() }
        .accessibilityIdentifier(A11yID.arenaRunSheet)
        .accessibilityLabel(ArenaRunSheetJudgment.spokenSheet(face: runSheetFace))
        .accessibilityValue(runSheetFace.productWord)
        .accessibilityHint(ArenaRunSheetJudgment.spokenSheetHint)
    }

    var runScrollBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                VStack(alignment: .leading, spacing: 8) {
                    ArenaPremiumKicker(text: ArenaNowJudgment.productNewMeasurement, tone: .active)
                    Text(ArenaNowJudgment.productWhatWeMeasure)
                        .font(AtlasFont.serif(34))
                        .foregroundStyle(AtlasTheme.textPrimary)
                    Text(ArenaNowJudgment.productMeasureOrderHonesty)
                        .font(.system(.callout))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                formSections
                planPreview
                statusBlocks
                submitButton
            }
            .padding(AtlasTheme.Space.screen)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: model.lastStartReceipt?.receiptHash)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: model.controlError)
        }
        .background(AtlasTheme.bg.ignoresSafeArea())
        .navigationTitle(ArenaRunSheetJudgment.productNavTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { runToolbar }
    }

    @ViewBuilder
    var planPreview: some View {
        if !selectedSuites.isEmpty, !selectedEngines.isEmpty, !selectedArms.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                ArenaPremiumKicker(text: ArenaNowJudgment.productPlan)
                Text(
                    "\(selectedEngines.count) \(selectedEngines.count == 1 ? "motor" : "motores") · "
                        + "\(selectedSuites.count) \(selectedSuites.count == 1 ? "suíte" : "suítes") · "
                        + "\(selectedEngines.count * selectedSuites.count * selectedArms.count) corridas"
                )
                .font(AtlasFont.mono(10, .medium))
                .foregroundStyle(AtlasTheme.textPrimary)
                Text(selectedArms.sorted { $0.rawValue < $1.rawValue }.map(\.labelPT).joined(separator: " → "))
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
            .padding(.vertical, 4)
        }
    }

    @ViewBuilder
    var statusBlocks: some View {
        if let error = model.controlError {
            Text(error)
                .font(.system(.callout))
                .foregroundStyle(AtlasTheme.alert)
                .accessibilityLabel(ArenaRunSheetJudgment.spokenErrorLabel(error))
                .transition(reduceMotion ? .identity : .opacity)
        }
        if let receipt = model.lastStartReceipt {
            receiptCard(receipt)
                .transition(reduceMotion ? .identity : .opacity.combined(with: .offset(y: 8)))
        }
    }

    var submitButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            Task { await model.startRuns(inputs: inputs) }
        } label: {
            Text(ArenaRunSheetJudgment.productNavTitle)
                .font(.system(.body, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(minHeight: 52)
                .background(Capsule().fill(input.isLocallyValidForSubmission ? AtlasTheme.goldVeil : AtlasTheme.surfaceHi))
                .overlay(Capsule().stroke(input.isLocallyValidForSubmission ? AtlasTheme.goldBorder : AtlasTheme.separator, lineWidth: 1))
        }
        .buttonStyle(PressableScale())
        .foregroundStyle(input.isLocallyValidForSubmission ? AtlasTheme.accent : AtlasTheme.textTertiary)
        .disabled(!input.isLocallyValidForSubmission)
        .accessibilityIdentifier(A11yID.arenaRunSubmit)
        .accessibilityLabel(ArenaStartJudgment.submitFace(input: input, enginesEmpty: engines.isEmpty, suitesEmpty: installedSuites.isEmpty).spokenLabel)
        .accessibilityHint(ArenaStartJudgment.submitFace(input: input, enginesEmpty: engines.isEmpty, suitesEmpty: installedSuites.isEmpty).spokenHint)
    }

    @ToolbarContentBuilder
    var runToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            AtlasCloseToolbarButton(
                spokenLabel: ArenaRunSheetJudgment.spokenClose,
                spokenHint: ArenaRunSheetJudgment.spokenCloseHint,
                reduceMotion: reduceMotion
            ) { dismiss() }
        }
    }

    var engines: [String] {
        let catalog = model.engineCatalog?.engines.map(\.engine) ?? []
        let composite = model.composite?.engines.map(\.engine) ?? []
        let suiteEngines = (model.scoreboard?.suites ?? []).flatMap { $0.engines.map(\.engine) }
        return Array(Set(catalog + composite + suiteEngines)).sorted()
    }

    var installedSuites: [AtlasArenaSuite] {
        (model.scoreboard?.suites ?? []).filter(\.adapterInstalled)
    }

    var input: AtlasArenaStartInput {
        payload(engine: selectedEngines.sorted().first ?? "")
    }

    var inputs: [AtlasArenaStartInput] {
        selectedEngines.sorted().map(payload(engine:))
    }

    func payload(engine: String) -> AtlasArenaStartInput {
        AtlasArenaStartInput(
            suites: .selected(Array(selectedSuites).sorted()),
            engine: engine,
            arms: AtlasArenaRunArm.allCases.filter { selectedArms.contains($0) },
            operatorActor: actor,
            operatorReason: reason,
            origin: UIDevice.current.userInterfaceIdiom == .pad ? "ipad" : "iphone"
        )
    }

    func seedDefaultsIfNeeded() {
        if selectedSuites.isEmpty, let first = installedSuites.first?.suite {
            selectedSuites.insert(first)
        }
        if engines.isEmpty {
            selectedEngines = []
        } else if selectedEngines.isEmpty, let first = engines.first {
            selectedEngines = [first]
        }
    }
}

// MARK: - ArenaSuiteSheet

// MARK: - Host

extension ArenaSuiteSheet {
    @ViewBuilder
    func engineHistorySparkline(_ engine: AtlasArenaSuiteEngine) -> some View {
        if !engine.history.isEmpty {
            SuiteSparkline(engine: engine).frame(height: 90)
                .accessibilityHidden(true)
        }
    }
}

extension ArenaSuiteSheet {
    @ViewBuilder
    func engineCardHeader(_ engine: AtlasArenaSuiteEngine) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(ArenaDisplay.engine(engine.engine))
                    .font(AtlasFont.serif(22))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text(ArenaNowJudgment.productSuiteIndexCaption)
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
            .accessibilityHidden(true)
            Spacer()
            engineCardScore(engine)
        }
    }
}

extension ArenaSuiteSheet {
    func engineCard(_ engine: AtlasArenaSuiteEngine) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            engineCardHeader(engine)
            ViewThatFits(in: .horizontal) {
                HStack(spacing: 28) {
                    suiteMetric("Sem Atlas", engine.withoutAtlasScore)
                    suiteMetric("Com Atlas", engine.withAtlasScore, tone: .active)
                    suiteMetric("Diferença", pairedDelta(engine), signed: true, tone: deltaTone(engine))
                }
                VStack(alignment: .leading, spacing: 12) {
                    suiteMetric("Sem Atlas", engine.withoutAtlasScore)
                    suiteMetric("Com Atlas", engine.withAtlasScore, tone: .active)
                    suiteMetric("Diferença", pairedDelta(engine), signed: true, tone: deltaTone(engine))
                }
            }
            ArenaPremiumHairline()
            engineEvidence(engine)
            if !engine.history.isEmpty {
                ArenaPremiumKicker(text: ArenaNowJudgment.productHistory)
                engineHistorySparkline(engine)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ArenaSuiteJudgment.spokenEngine(engine))
    }

    private func suiteMetric(
        _ label: String,
        _ value: Double?,
        signed: Bool = false,
        tone: ArenaPremiumTone = .neutral
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(signed ? ArenaFormat.signed(value) : ArenaFormat.score(value))
                .font(AtlasFont.serif(28))
                .foregroundStyle(tone.color)
            Text(label)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
    }

    private func engineEvidence(_ engine: AtlasArenaSuiteEngine) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let cases = ArenaSuiteJudgment.casesCaption(for: engine) {
                evidenceLine(cases, symbol: "checklist")
            }
            if let duration = ArenaSuiteJudgment.durationCaption(for: engine) {
                evidenceLine(duration, symbol: "timer")
            }
            evidenceLine("mesma suíte · braços equivalentes", symbol: "equal.circle")
        }
        .font(AtlasFont.mono(10))
        .foregroundStyle(AtlasTheme.textSecondary)
    }

    private func evidenceLine(_ text: String, symbol: String) -> some View {
        HStack(spacing: 8) {
            ArenaPremiumIcon(symbol: symbol, tone: .neutral, role: .compact)
            Text(text)
        }
    }

    private func pairedDelta(_ engine: AtlasArenaSuiteEngine) -> Double? {
        guard let withAtlas = engine.withAtlasScore,
              let withoutAtlas = engine.withoutAtlasScore else { return nil }
        return withAtlas - withoutAtlas
    }

    private func deltaTone(_ engine: AtlasArenaSuiteEngine) -> ArenaPremiumTone {
        guard let delta = pairedDelta(engine), abs(delta) > 0.005 else { return .neutral }
        return delta > 0 ? .positive : .negative
    }
}

// MARK: - Body

extension ArenaSuiteSheet {
    func engineCardScore(_ engine: AtlasArenaSuiteEngine) -> some View {
        HStack(alignment: .lastTextBaseline, spacing: 3) {
            Text(ArenaFormat.score(engine.score))
                .font(AtlasFont.serif(38))
            if engine.score != nil {
                Text("/10")
                    .font(AtlasFont.mono(9, .medium))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
        }
            .foregroundStyle(engine.score == nil ? AtlasTheme.textTertiary : AtlasTheme.textPrimary)
            .accessibilityHidden(true)
    }
}

extension ArenaSuiteSheet {
    /// WAVE-059: suite face + ranked engines.
    var suiteFace: ArenaSuiteFace {
        ArenaSuiteJudgment.face(for: suite)
    }

    var rankedEngines: [AtlasArenaSuiteEngine] {
        ArenaSuiteJudgment.rank(suite.engines)
    }

    var suiteBodyTitle: some View {
        VStack(alignment: .leading, spacing: 8) {
            ArenaPremiumKicker(
                text: suiteFace.kicker,
                tone: suiteFace.productWord == "regression" ? .negative : .active
            )
            Text(ArenaDisplay.suite(suite.suite))
                .font(AtlasFont.serif(34))
                .foregroundStyle(AtlasTheme.textPrimary)
            HStack(spacing: 12) {
                metadata("\(suite.runsTotal) rodadas", symbol: "circle.grid.2x2")
                if let last = ArenaDisplay.relative(suite.lastRunAt) {
                    metadata(last, symbol: "clock")
                }
            }
            .font(AtlasFont.mono(10))
            .foregroundStyle(AtlasTheme.textSecondary)
        }
        .accessibilityAddTraits(.isHeader)
        .accessibilityLabel(ArenaSuiteJudgment.spokenSuite(suite))
        .accessibilityValue(suiteFace.productWord)
    }

    private func metadata(_ text: String, symbol: String) -> some View {
        HStack(spacing: 5) {
            ArenaPremiumIcon(symbol: symbol, tone: .neutral, role: .compact)
            Text(text)
        }
    }
}

extension ArenaSuiteSheet {
    var suiteScrollBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                suiteBodyTitle
                // WAVE-059: regressed engines first.
                ForEach(rankedEngines) { engine in
                    engineCard(engine)
                    ArenaPremiumHairline()
                }
                Text(ArenaNowJudgment.productSuiteAbsentHonesty)
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            .padding(AtlasTheme.Space.screen)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: suite.engines.count)
        }
        .background(AtlasTheme.bg.ignoresSafeArea())
        .navigationTitle(ArenaSuiteJudgment.productTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { suiteToolbar }
    }
}

extension ArenaSuiteSheet {
    var suitePresentation: some View {
        NavigationStack {
            suiteScrollBody
                .accessibilityIdentifier(A11yID.arenaSuiteSheet)
        }
    }
}

extension ArenaSuiteSheet {
    @ToolbarContentBuilder
    var suiteToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            AtlasCloseToolbarButton(
                spokenLabel: ArenaSuiteJudgment.spokenClose,
                spokenHint: ArenaSuiteJudgment.spokenCloseHint,
                reduceMotion: reduceMotion
            ) { dismiss() }
        }
    }
}

struct ArenaSuiteSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let suite: AtlasArenaSuite

    var body: some View {
        suitePresentation
    }
}
