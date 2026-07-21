import AtlasCore
import SwiftUI

// Cycle 039 fuse → ArenaSuiteSheet+EngineCard.swift

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
