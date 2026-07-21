import AtlasCore
import Foundation
import SwiftUI

// Cycle 044 fuse → ArenaSuiteSheet.swift

// MARK: - Arena suite sheet

struct ArenaSuiteSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let suite: AtlasArenaSuite

    var body: some View {
        suitePresentation
    }
}

// Casos/duração só quando o servidor publica; zero «0» fabricado.

enum ArenaSuiteSheetA11y {
    static func spokenSuiteTitle(_ suite: String) -> String {
        "suite \(suite)"
    }
}

enum ArenaSuiteSheetA11yCaptions {
    static func casesCaption(for engine: AtlasArenaSuiteEngine) -> String? {
        guard let total = engine.casesTotal else { return nil }
        var parts: [String] = []
        if let passed = engine.casesPassed { parts.append("ok \(passed)") }
        if let failed = engine.casesFailed { parts.append("falha \(failed)") }
        parts.append("de \(total) casos")
        return parts.joined(separator: " · ")
    }

    static func durationCaption(for engine: AtlasArenaSuiteEngine) -> String? {
        guard let ms = engine.durationAvgMs else { return nil }
        return "duração média \(ArenaDisplay.duration(ms: ms)) por caso"
    }
}

extension ArenaSuiteSheetA11y {
    static let closeLabel = "fechar detalhes da suite"
    static let closeHint = "volta para a Arena"
    static let sheetHint = "scores, casos e duração só quando o servidor publica"
}

extension ArenaSuiteSheetA11y {
    static func spokenEngine(_ engine: AtlasArenaSuiteEngine) -> String {
        var parts = [engine.engine, "score \(ArenaFormat.score(engine.score))"]
        if engine.regressed { parts.append("regressão detectada") }
        if let cases = ArenaSuiteSheetA11yCaptions.casesCaption(for: engine) { parts.append(cases) }
        if let duration = ArenaSuiteSheetA11yCaptions.durationCaption(for: engine) { parts.append(duration) }
        if !engine.history.isEmpty {
            parts.append("\(engine.history.count) pontos no histórico")
        }
        return parts.joined(separator: ", ")
    }
}

extension ArenaSuiteSheetA11y {
    static func spokenSheet(_ suite: AtlasArenaSuite) -> String {
        let n = suite.engines.count
        if n == 0 {
            return "suite \(suite.suite), nenhum motor neste recorte"
        }
        return "suite \(suite.suite), \(n) motor\(n == 1 ? "" : "es")"
    }
}

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
    var suitePresentation: some View {
        NavigationStack {
            suiteScrollBody
                .accessibilityIdentifier(A11yID.arenaSuiteSheet)
                // Contain: suite header and engine cards stay separately focusable.
                .accessibilityElement(children: .contain)
        }
    }
}

extension ArenaSuiteSheet {
    @ToolbarContentBuilder
    var suiteToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            AtlasCloseToolbarButton(
                spokenLabel: ArenaSuiteSheetA11y.closeLabel,
                spokenHint: ArenaSuiteSheetA11y.closeHint,
                reduceMotion: reduceMotion
            ) { dismiss() }
        }
    }
}

extension ArenaSuiteSheet {
    var suiteBodyTitle: some View {
        VStack(alignment: .leading, spacing: 8) {
            ArenaPremiumKicker(
                text: suite.hasRegression ? "Regressão detectada" : "Resultado da suíte",
                tone: suite.hasRegression ? .negative : .active
            )
            Text(ArenaDisplay.suite(suite.suite))
                .font(AtlasFont.serif(34))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
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
        .accessibilityLabel(ArenaSuiteSheetA11y.spokenSuiteTitle(suite.suite))
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
                ForEach(suite.engines) { engine in
                    engineCard(engine)
                    ArenaPremiumHairline()
                }
                Text("Valores ausentes permanecem não medidos. Comparações só aparecem quando os dois braços foram publicados.")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
            .padding(AtlasTheme.Space.screen)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: suite.engines.count)
        }
        .background(AtlasTheme.bg.ignoresSafeArea())
        .navigationTitle("Suite")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { suiteToolbar }
    }
}

extension ArenaSuiteSheet {
    @ViewBuilder
    func engineCardHeader(_ engine: AtlasArenaSuiteEngine) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(ArenaDisplay.engine(engine.engine))
                    .font(AtlasFont.serif(21))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text("Índice da suíte · escala 0–10")
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
                ArenaPremiumKicker(text: "Histórico")
                engineHistorySparkline(engine)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(ArenaSuiteSheetA11y.spokenEngine(engine))
    }

    private func suiteMetric(
        _ label: String,
        _ value: Double?,
        signed: Bool = false,
        tone: ArenaPremiumTone = .neutral
    ) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(signed ? ArenaFormat.signed(value) : ArenaFormat.score(value))
                .font(AtlasFont.serif(29))
                .foregroundStyle(tone.color)
            Text(label)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(label), \(signed ? ArenaFormat.signed(value) : ArenaFormat.score(value))"
        )
    }

    private func engineEvidence(_ engine: AtlasArenaSuiteEngine) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let cases = ArenaSuiteSheetA11yCaptions.casesCaption(for: engine) {
                evidenceLine(cases, symbol: "checklist")
            }
            if let duration = ArenaSuiteSheetA11yCaptions.durationCaption(for: engine) {
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel(text)
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
