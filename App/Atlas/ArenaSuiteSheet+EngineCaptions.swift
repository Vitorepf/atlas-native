import AtlasCore
import Foundation
import SwiftUI

// Cycle 039 fuse → ArenaSuiteSheet+EngineCaptions.swift

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
    func engineCasesCaption(_ engine: AtlasArenaSuiteEngine) -> some View {
        if let cases = ArenaSuiteSheetA11yCaptions.casesCaption(for: engine) {
            Text(cases)
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textSecondary)
                .accessibilityHidden(true)
        }
    }
}

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
    func engineCardCaptions(_ engine: AtlasArenaSuiteEngine) -> some View {
        engineCasesCaption(engine)
        engineDurationCaption(engine)
        engineHistorySparkline(engine)
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
