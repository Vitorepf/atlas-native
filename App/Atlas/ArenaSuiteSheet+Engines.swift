import SwiftUI
import AtlasCore

// WAVE-010 fused SuiteSheet engines+captions

// --- ArenaSuiteSheet+EngineCaptions+Cases.swift ---
extension ArenaSuiteSheet {
    @ViewBuilder
    func engineCasesCaption(_ engine: AtlasArenaSuiteEngine) -> some View {
        if let cases = ArenaSuiteSheetA11yCaptions.casesCaption(for: engine) {
            Text(cases)
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
        }
    }
}

// --- ArenaSuiteSheet+EngineCaptions+Duration.swift ---
extension ArenaSuiteSheet {
    @ViewBuilder
    func engineDurationCaption(_ engine: AtlasArenaSuiteEngine) -> some View {
        if let duration = ArenaSuiteSheetA11yCaptions.durationCaption(for: engine) {
            Text(duration)
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
    }
}

// --- ArenaSuiteSheet+EngineCaptions+Sparkline.swift ---
extension ArenaSuiteSheet {
    @ViewBuilder
    func engineHistorySparkline(_ engine: AtlasArenaSuiteEngine) -> some View {
        if !engine.history.isEmpty {
            SuiteSparkline(engine: engine).frame(height: 90)
                .accessibilityHidden(true)
        }
    }
}

// --- ArenaSuiteSheet+EngineCaptions.swift ---
extension ArenaSuiteSheet {
    @ViewBuilder
    func engineCardCaptions(_ engine: AtlasArenaSuiteEngine) -> some View {
        engineCasesCaption(engine)
        engineDurationCaption(engine)
        engineHistorySparkline(engine)
    }
}

// --- ArenaSuiteSheet+EngineCard+Header.swift ---
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

// --- ArenaSuiteSheet+EngineCard.swift ---
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

// --- ArenaSuiteSheet+EngineScore.swift ---
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

