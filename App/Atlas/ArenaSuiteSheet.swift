import SwiftUI
import AtlasCore

// WAVE-010 fused SuiteSheet host/body/presentation

// --- ArenaSuiteSheet+Body+TitleHeader.swift ---
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

// --- ArenaSuiteSheet+Body.swift ---
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

// --- ArenaSuiteSheet+Presentation.swift ---
extension ArenaSuiteSheet {
    var suitePresentation: some View {
        NavigationStack {
            suiteScrollBody
                .accessibilityIdentifier(A11yID.arenaSuiteSheet)
        }
    }
}

// --- ArenaSuiteSheet+Toolbar.swift ---
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

// --- ArenaSuiteSheet.swift ---
// MARK: - Arena suite sheet
// Engine card → +EngineCard · Toolbar → +Toolbar.swift
// Body → ArenaSuiteSheet+Body.swift
// Presentation → ArenaSuiteSheet+Presentation.swift

struct ArenaSuiteSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    let suite: AtlasArenaSuite

    var body: some View {
        suitePresentation
    }
}

