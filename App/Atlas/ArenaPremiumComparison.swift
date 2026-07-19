import SwiftUI
import AtlasCore

struct ArenaPremiumComparison: View {
    @Bindable var model: ArenaModel
    let provisional: Bool

    private var suiteEngine: AtlasArenaSuiteEngine? {
        guard let run = model.arenaPrimaryRun else {
            return model.arenaPrimarySuite?.engines.first
        }
        return model.arenaPrimarySuite?.engines.first { $0.engine == run.engine }
            ?? model.arenaPrimarySuite?.engines.first
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ArenaPremiumHairline()
            ArenaPremiumKicker(
                text: provisional ? "Último par publicado · escala 0–10" : "Comparação final · escala 0–10"
            )
            if let suiteEngine,
               suiteEngine.withoutAtlasScore != nil,
               suiteEngine.withAtlasScore != nil {
                values(suiteEngine)
                Text(provisional ? "Referência anterior · ainda não atribuída à medição em curso" : "Mesmos casos · mesma ordem")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
            } else {
                Text("A comparação aparece quando os dois braços equivalentes terminarem.")
                    .font(.system(.callout))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
        }
    }

    private func values(_ value: AtlasArenaSuiteEngine) -> some View {
        let delta = (value.withAtlasScore ?? 0) - (value.withoutAtlasScore ?? 0)
        return HStack(alignment: .lastTextBaseline, spacing: 18) {
            metric(ArenaFormat.score(value.withoutAtlasScore), "Sem Atlas")
            ArenaPremiumIcon(
                symbol: ArenaPremiumIconography.comparison,
                tone: .muted,
                role: .compact
            )
            metric(ArenaFormat.score(value.withAtlasScore), "Com Atlas")
            Spacer(minLength: 2)
            // Delta com rótulo — número órfão flutuando na borda era quebra.
            VStack(alignment: .trailing, spacing: 4) {
                Text(ArenaFormat.signed(delta))
                    .font(AtlasFont.mono(15, .medium))
                    .foregroundStyle(abs(delta) < 0.005 ? AtlasTheme.textSecondary : (delta > 0 ? AtlasTheme.textPrimary : AtlasTheme.alert))
                Text("diferença")
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textTertiary)
            }
        }
    }

    private func metric(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(AtlasFont.serif(29))
                .foregroundStyle(AtlasTheme.textPrimary)
            Text(label)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
    }
}
