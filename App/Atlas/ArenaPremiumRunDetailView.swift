import SwiftUI
import AtlasCore

/// Detalhe de uma corrida: progresso + casos (lista real = §5 Core).
struct ArenaPremiumRunDetailView: View {
    let run: AtlasArenaLiveRun

    private var fraction: Double? {
        guard let done = run.casesDone, let total = run.casesTotal, total > 0 else { return nil }
        return Double(min(max(0, done), total)) / Double(total)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header
                progressBlock
                casesBlock
            }
            .padding(.horizontal, AtlasTheme.Space.screen)
            .padding(.top, 18)
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .background(AtlasTheme.bg.ignoresSafeArea())
        .navigationTitle(ArenaDisplay.suite(run.suite))
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityIdentifier(A11yID.arenaPremiumRunDetail)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            ArenaPremiumKicker(
                text: statusLabel,
                tone: statusTone,
                showsLiveMark: run.status == .running || run.status == .stopping
            )
            Text(ArenaDisplay.suite(run.suite))
                .font(AtlasFont.serif(28))
                .foregroundStyle(AtlasTheme.textPrimary)
            if let arm = run.arm?.labelPT {
                Text(arm)
                    .font(AtlasFont.mono(12))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
        }
    }

    @ViewBuilder
    private var progressBlock: some View {
        if let done = run.casesDone, let total = run.casesTotal, total > 0, let fraction {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .lastTextBaseline, spacing: 8) {
                    Text("\(min(done, total))")
                        .font(AtlasFont.serif(44))
                        .foregroundStyle(AtlasTheme.textPrimary)
                    Text("de \(total) casos")
                        .font(AtlasFont.serif(18))
                        .foregroundStyle(AtlasTheme.textSecondary)
                    Spacer()
                    Text("\(Int((fraction * 100).rounded(.down)))%")
                        .font(AtlasFont.mono(16, .medium))
                        .foregroundStyle(AtlasTheme.accent)
                }
                Text(summaryLine(done: min(done, total), total: total))
                    .font(AtlasFont.mono(11))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
        } else {
            Text("Denominador de casos ainda não publicado nesta corrida.")
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textSecondary)
        }
    }

    private var casesBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Casos")
                .font(AtlasFont.mono(10, .medium))
                .tracking(1.4)
                .foregroundStyle(AtlasTheme.textTertiary)
                .textCase(.uppercase)
            Text("Lista por teste ainda não publicada pelo servidor. Quando o contrato chegar, cada caso aparece aqui — feitos, ao vivo e a seguir.")
                .font(AtlasFont.mono(12))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityIdentifier(A11yID.arenaPremiumRunDetailCases)
    }

    private func summaryLine(done: Int, total: Int) -> String {
        ArenaRunStatusJudgment.casesSummaryLine(
            status: run.status,
            done: done,
            total: total
        )
    }

    private var statusLabel: String {
        ArenaRunStatusJudgment.label(for: run.status)
    }

    private var statusTone: ArenaPremiumTone {
        ArenaRunStatusJudgment.tone(for: run.status)
    }
}
