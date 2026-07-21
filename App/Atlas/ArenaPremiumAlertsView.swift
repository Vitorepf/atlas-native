import SwiftUI
import AtlasCore

struct ArenaPremiumAlertsView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
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
            ArenaPremiumKicker(
                text: hasAlerts ? "Exceções que pedem atenção" : "Sem exceções",
                tone: hasAlerts ? .negative : .positive
            )
            .accessibilityIdentifier(A11yID.arenaPremiumAlerts)
            HStack(alignment: .lastTextBaseline, spacing: 7) {
                Text("\(regressions.count + reportAlerts.count)")
                    .font(AtlasFont.serif(58))
                    .foregroundStyle(hasAlerts ? AtlasTheme.alert : AtlasTheme.textPrimary)
                Text("alertas")
                    .font(AtlasFont.mono(11))
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
                Button {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    onSuite(suite)
                } label: {
                    alertRow(
                        title: ArenaDisplay.suite(suite.suite),
                        detail: regressionDetail(suite),
                        symbol: "arrow.down.right"
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(
                    "\(ArenaDisplay.suite(suite.suite)), \(regressionDetail(suite))"
                )
                .accessibilityHint("abre a suíte com regressão")
                .accessibilityAddTraits(.isButton)
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
                    Text("Nenhuma regressão ou falha publicada")
                }
                    .font(.system(.callout))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .frame(maxWidth: .infinity, minHeight: 86, alignment: .leading)
            }
        }
    }

    @ViewBuilder
    private var blockers: some View {
        if let blockers = model.report?.claimBlockers, !blockers.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                ArenaPremiumKicker(text: "Publicação bloqueada")
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
                .atlasSans(16, .medium)
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
        return "\(ArenaFormat.signed(delta)) · regressão"
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
