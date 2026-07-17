import SwiftUI
import Charts
import AtlasCore

struct AtlasArenaView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Bindable var model: ArenaModel

    var body: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    header
                    if let exception = model.regressionException {
                        exceptionBanner(exception)
                    }
                    content
                }
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.vertical, 18)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Arena")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier(A11yID.arenaScreen)
        .task {
            if case .idle = model.phase {
                await model.load()
            }
        }
        .refreshable { await model.load() }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("ARENA")
                .font(.system(.caption, weight: .semibold))
                .tracking(1.5)
                .foregroundStyle(AtlasTheme.textTertiary)
            Text("Medição dos motores")
                .font(AtlasFont.serif(28, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
            if let age = model.snapshotAgeText {
                Text("snapshot \(age)")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Arena, medição dos motores")
    }

    @ViewBuilder
    private var content: some View {
        switch model.phase {
        case .idle where model.composite == nil,
             .loading where model.composite == nil:
            loadingCard
        case .failed(let message) where model.composite == nil:
            stateCard(message)
        default:
            if let composite = model.composite {
                ArenaIndexSection(composite: composite, reduceMotion: reduceMotion)
                    .accessibilityIdentifier(A11yID.arenaIndexSection)
                ArenaCapabilitiesSection(capabilities: model.capabilities)
                    .accessibilityIdentifier(A11yID.arenaCapabilitiesSection)
            } else {
                stateCard("medição ainda não publicada pelo servidor")
            }
        }
    }

    private var loadingCard: some View {
        HStack(spacing: 12) {
            BreathingDiamond(size: 9, reduceMotion: reduceMotion)
            Text("carregando índice medido…")
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .atlasCard()
    }

    private func stateCard(_ message: String) -> some View {
        Text(message)
            .font(.system(.subheadline))
            .foregroundStyle(AtlasTheme.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .atlasCard()
    }

    private func exceptionBanner(_ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(AtlasTheme.alert)
            Text(text)
                .font(.system(.callout, weight: .medium))
                .foregroundStyle(AtlasTheme.textPrimary)
                .lineLimit(2)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14).fill(AtlasTheme.alert.opacity(0.10)))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AtlasTheme.alert.opacity(0.35), lineWidth: 1))
    }
}

private struct ArenaIndexSection: View {
    let composite: AtlasArenaComposite
    let reduceMotion: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader
            ForEach(composite.engines) { engine in
                ArenaEngineIndexRow(engine: engine)
            }
            if let engine = composite.engines.first, !engine.history.isEmpty {
                ArenaCompositeChart(engine: engine, reduceMotion: reduceMotion)
                    .frame(height: 170)
                    .padding(.top, 4)
            }
        }
        .padding(16)
        .atlasCard()
    }

    private var sectionHeader: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 3) {
                Text("O ÍNDICE")
                    .font(.system(.caption, weight: .semibold))
                    .tracking(1.4)
                    .foregroundStyle(AtlasTheme.textTertiary)
                Text("cobertura \(composite.suitesMeasured)/\(composite.suitesTotal) · parcial")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            Spacer()
            Text("\(composite.weightsPublic.count) pesos")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
    }
}

private struct ArenaEngineIndexRow: View {
    let engine: AtlasArenaCompositeEngine

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Text(engine.engine)
                    .font(.system(.body, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .lineLimit(1)
                Spacer(minLength: 8)
                Text(ArenaFormat.score(engine.composite))
                    .font(AtlasFont.mono(18))
                    .foregroundStyle(engine.composite == nil ? AtlasTheme.textTertiary : AtlasTheme.textPrimary)
                    .monospacedDigit()
                Text(ArenaFormat.signed(engine.delta))
                    .font(AtlasFont.mono(12))
                    .foregroundStyle((engine.delta ?? 0) < 0 ? AtlasTheme.alert : AtlasTheme.accent)
                    .monospacedDigit()
            }
            HStack(spacing: 10) {
                metric("c/Atlas", ArenaFormat.score(engine.withAtlasComposite), color: AtlasTheme.accent)
                metric("sem", ArenaFormat.score(engine.withoutAtlasComposite), color: AtlasTheme.textSecondary)
                metric("N×M", ArenaFormat.multiplier(engine.atlasMultiplier), color: AtlasTheme.textPrimary)
            }
            if engine.isPartialCoverage {
                Text("cobertura parcial \(Int((engine.coverage * 100).rounded()))%")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
    }

    private func metric(_ label: String, _ value: String, color: Color) -> some View {
        Text("\(label) \(value)")
            .font(AtlasFont.mono(11))
            .foregroundStyle(color)
            .monospacedDigit()
    }

    private var accessibilityText: String {
        "\(engine.engine), composto \(ArenaFormat.score(engine.composite)), variação \(ArenaFormat.signed(engine.delta)), com Atlas \(ArenaFormat.score(engine.withAtlasComposite)), multiplicador \(ArenaFormat.multiplier(engine.atlasMultiplier))"
    }
}

private struct ArenaCompositeChart: View {
    let engine: AtlasArenaCompositeEngine
    let reduceMotion: Bool

    var body: some View {
        Chart {
            ForEach(engine.history) { point in
                if let composite = point.composite {
                    LineMark(
                        x: .value("rodada", point.roundAt),
                        y: .value("composto", composite)
                    )
                    .foregroundStyle(AtlasTheme.accent)
                    .interpolationMethod(reduceMotion ? .linear : .catmullRom)
                }
                if let withAtlas = point.withAtlas {
                    LineMark(
                        x: .value("rodada", point.roundAt),
                        y: .value("com Atlas", withAtlas),
                        series: .value("série", "com Atlas")
                    )
                    .foregroundStyle(AtlasTheme.accent.opacity(0.65))
                    .interpolationMethod(.linear)
                }
                if let withoutAtlas = point.withoutAtlas {
                    LineMark(
                        x: .value("rodada", point.roundAt),
                        y: .value("sem Atlas", withoutAtlas),
                        series: .value("série", "sem Atlas")
                    )
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .interpolationMethod(.linear)
                }
            }
        }
        .chartLegend(.visible)
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .accessibilityLabel("histórico do índice \(engine.engine)")
    }
}

private struct ArenaCapabilitiesSection: View {
    let capabilities: AtlasArenaCapabilities?

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("CAPACIDADES")
                        .font(.system(.caption, weight: .semibold))
                        .tracking(1.4)
                        .foregroundStyle(AtlasTheme.textTertiary)
                    Text(capabilities?.engine ?? "motor não selecionado")
                        .font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasTheme.textTertiary)
                }
                Spacer()
                Text(capabilities?.mappingVersion ?? "não medido")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(capabilities == nil ? AtlasTheme.textTertiary : AtlasTheme.textSecondary)
            }

            if let capabilities, !capabilities.capabilities.isEmpty {
                ForEach(capabilities.capabilities) { capability in
                    ArenaCapabilityRow(capability: capability)
                }
                ArenaCapabilitiesChart(capabilities: capabilities.capabilities)
                    .frame(height: 190)
            } else {
                Text("não medido")
                    .font(AtlasFont.mono(13))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
                    .accessibilityLabel("capacidades não medidas")
            }
        }
        .padding(16)
        .atlasCard()
    }
}

private struct ArenaCapabilityRow: View {
    let capability: AtlasArenaCapability

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            HStack(alignment: .firstTextBaseline) {
                Text(capability.labelPt)
                    .font(.system(.callout, weight: .medium))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .lineLimit(1)
                Spacer()
                Text("\(ArenaFormat.score(capability.score)) · c/A \(ArenaFormat.score(capability.withAtlas))")
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(capability.score == nil ? AtlasTheme.textTertiary : AtlasTheme.textSecondary)
                    .monospacedDigit()
            }
            DualBar(score: capability.score, withAtlas: capability.withAtlas)
            Text("\(capability.casesTotal ?? 0) casos · \(capability.suitesContributing.joined(separator: ", "))")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(capability.labelPt), score \(ArenaFormat.score(capability.score)), com Atlas \(ArenaFormat.score(capability.withAtlas))")
    }
}

private struct DualBar: View {
    let score: Double?
    let withAtlas: Double?

    var body: some View {
        VStack(spacing: 4) {
            bar(score, color: AtlasTheme.textSecondary)
            bar(withAtlas, color: AtlasTheme.accent)
        }
        .accessibilityHidden(true)
    }

    private func bar(_ value: Double?, color: Color) -> some View {
        GeometryReader { proxy in
            let width = proxy.size.width * min(max(value ?? 0, 0), 1)
            ZStack(alignment: .leading) {
                Capsule().fill(AtlasTheme.surfaceHi.opacity(0.8))
                Capsule()
                    .fill(value == nil ? AtlasTheme.textTertiary.opacity(0.25) : color.opacity(0.85))
                    .frame(width: width)
            }
        }
        .frame(height: 5)
    }
}

private struct ArenaCapabilitiesChart: View {
    let capabilities: [AtlasArenaCapability]

    private struct Point: Identifiable {
        let id = UUID()
        let label: String
        let series: String
        let value: Double
    }

    private var points: [Point] {
        capabilities.flatMap { capability in
            [
                capability.score.map { Point(label: capability.labelPt, series: "sem Atlas", value: $0) },
                capability.withAtlas.map { Point(label: capability.labelPt, series: "com Atlas", value: $0) },
            ].compactMap { $0 }
        }
    }

    var body: some View {
        Chart(points) { point in
            BarMark(
                x: .value("score", point.value),
                y: .value("capacidade", point.label)
            )
            .position(by: .value("série", point.series))
            .foregroundStyle(point.series == "com Atlas" ? AtlasTheme.accent : AtlasTheme.textSecondary)
        }
        .chartXScale(domain: 0...1)
        .chartLegend(.visible)
        .chartXAxis {
            AxisMarks(values: [0, 0.5, 1])
        }
        .chartYAxis(.hidden)
        .accessibilityLabel("barras de capacidades medidas")
    }
}
