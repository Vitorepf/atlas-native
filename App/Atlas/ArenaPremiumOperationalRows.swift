import SwiftUI
import AtlasCore

struct ArenaPremiumOperationalRows: View {
    @Bindable var model: ArenaModel
    let onNavigate: (ArenaPremiumDestination) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ArenaPremiumHairline()
            ArenaPremiumDisclosureRow(
                title: "Plano",
                detail: planDetail,
                symbol: ArenaPremiumIconography.plan,
                tone: .active
            ) { onNavigate(.plan) }
            .accessibilityIdentifier(A11yID.arenaPremiumPlanAction)
            ArenaPremiumHairline()
            ArenaPremiumDisclosureRow(
                title: "Fila",
                detail: queueDetail,
                symbol: ArenaPremiumIconography.queue,
                tone: .neutral
            ) { onNavigate(.queue) }
            .accessibilityIdentifier(A11yID.arenaPremiumQueueAction)
            ArenaPremiumHairline()
            ArenaPremiumDisclosureRow(
                title: "Alertas",
                detail: alertDetail,
                symbol: ArenaPremiumIconography.alerts,
                tone: model.arenaRegressionCount > 0 ? .negative : .neutral
            ) { onNavigate(.alerts) }
            .accessibilityIdentifier(A11yID.arenaPremiumAlertsAction)
            ArenaPremiumHairline()
            ArenaPremiumDisclosureRow(
                title: "Cobertura",
                detail: model.arenaCoverageText,
                symbol: ArenaPremiumIconography.coverage,
                tone: .neutral
            ) { onNavigate(.plan) }
            nextRow
        }
    }

    private var planDetail: String {
        guard let plan = model.activePlan else {
            return model.livePresentation?.primaryRun == nil ? "nenhum ativo" : "em andamento"
        }
        return "\(plan.suites.count) suítes"
    }

    private var queueDetail: String {
        let count = model.livePresentation?.queuedSuites.count ?? 0
        return count == 1 ? "1 suíte" : "\(count) suítes"
    }

    private var alertDetail: String {
        let count = model.arenaAlertSuiteCount
        if count == 0 { return "nenhuma exceção" }
        return count == 1 ? "1 exceção" : "\(count) exceções"
    }

    @ViewBuilder
    private var nextRow: some View {
        if let suite = model.livePresentation?.queuedSuites.first {
            ArenaPremiumHairline()
            ArenaPremiumDisclosureRow(
                title: "Próxima",
                detail: ArenaDisplay.suite(suite),
                symbol: ArenaPremiumIconography.next,
                tone: .neutral
            ) { onNavigate(.queue) }
        }
    }
}
