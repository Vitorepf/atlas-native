import SwiftUI
import AtlasCore

struct ArenaPremiumCapabilityDetail: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
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
            ArenaPremiumKicker(text: "Capacidade medida · escala 0–10")
                        .accessibilityIdentifier(A11yID.arenaPremiumCapabilityDetail)
                    Text(capability.labelPt)
                        .font(AtlasFont.serif(34))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .accessibilityAddTraits(.isHeader)
                    comparison
                    contribution
                    provenance
                }
                .padding(AtlasTheme.Space.screen)
            }
            .scrollIndicators(.hidden)
            .background(AtlasTheme.bg.ignoresSafeArea())
            .navigationTitle("Capacidade")
            .navigationBarTitleDisplayMode(.inline)
            // Contain: title, comparison and provenance stay separately focusable.
            .accessibilityElement(children: .contain)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    AtlasCloseToolbarButton(
                        spokenLabel: "fechar capacidade",
                        spokenHint: "volta para o perfil",
                        reduceMotion: reduceMotion
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
                    Text("diferença \(ArenaFormat.signed(delta))")
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
            ArenaPremiumKicker(text: "Suítes que contribuíram")
                .padding(.bottom, 10)
            ArenaPremiumHairline()
            ForEach(capability.suitesContributing, id: \.self) { suite in
                HStack {
                    ArenaPremiumIcon(
                        symbol: ArenaPremiumIconography.suite(suite)
                    )
                    Text(ArenaDisplay.suite(suite))
                        .atlasSans(16, .medium)
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
            ArenaPremiumKicker(text: "Proveniência")
            // "denominador" é jargão de estatístico — português direto.
            Text("\(capability.casesTotal.map(String.init) ?? "—") casos somados na conta publicada")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textSecondary)
            Text("Ausência de um braço permanece não medida.")
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
