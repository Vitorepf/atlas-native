import SwiftUI
import AtlasCore

enum AutonomosDetailSheet: String, Identifiable {
    case workOrders
    case inbox
    case budgets
    case findings

    var id: String { rawValue }
    var title: String {
        switch self {
        case .workOrders: return "Work orders"
        case .inbox: return "Inbox"
        case .budgets: return "Budgets"
        case .findings: return "Findings"
        }
    }
}

struct AutonomosPublicDetailSheet: View {
    let kind: AutonomosDetailSheet
    let backlog: AtlasAutonomosBacklogResponse?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    if let backlog {
                        content(backlog)
                    } else {
                        Text("Sem projeção pública disponível agora.")
                            .font(.footnote)
                            .foregroundStyle(AtlasTheme.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .atlasCard(cornerRadius: 12)
                    }
                }
                .padding(AtlasTheme.Space.screen)
            }
            .background(AtlasTheme.bg.ignoresSafeArea())
            .navigationTitle(kind.title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Fechar") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationBackground(AtlasTheme.bg)
        .accessibilityIdentifier(A11yID.autonomosDetailSheet)
    }

    @ViewBuilder
    private func content(_ backlog: AtlasAutonomosBacklogResponse) -> some View {
        switch kind {
        case .workOrders:
            ForEach(backlog.workOrders) { item in
                detailCard(item.title) {
                    detailField("id", item.workOrderId)
                    detailField("finding", item.findingHash)
                    detailField("route", item.route)
                    detailField("owner service", item.routesToOwnerService)
                    detailField("risk", item.riskLevel)
                    detailField("priority", "\(item.priorityScore)")
                    detailField("status", item.status)
                    if let createdAt = item.createdAt {
                        detailField("criado", createdAt)
                        if let date = AtlasTime.date(createdAt) {
                            detailField("idade", AutonomosChrome.relativeAge(from: date))
                        }
                    }
                    detailField("branch isolation", item.requiresBranchIsolation ? "sim" : "não")
                    detailField("decisão do operador", item.operatorDecisionRequired ? "sim" : "não")
                    detailField("evidência exigida", item.evidenceRequired ? "sim" : "não")
                    detailField("execução feita", item.executionExecuted ? "sim" : "não")
                }
            }
        case .inbox:
            ForEach(backlog.inboxItems) { item in
                detailCard(item.title) {
                    detailField("finding", item.findingHash)
                    detailField("route", item.route)
                    detailField("risk", item.riskLevel)
                    detailField("priority", "\(item.priorityScore)")
                    if let createdAt = item.createdAt {
                        detailField("criado", createdAt)
                        if let date = AtlasTime.date(createdAt) {
                            detailField("idade", AutonomosChrome.relativeAge(from: date))
                        }
                    }
                    detailField("decisão exigida", item.decisionRequired ? "sim" : "não")
                    detailField("opções", item.decisionOptions.joined(separator: " · "))
                }
            }
        case .findings:
            detailCard("Resumo") {
                detailField("total", "\(backlog.findings.total)")
                detailField("distintos", "\(backlog.findings.distinctTotal)")
                detailField("retornados", "\(backlog.findings.returned)")
                detailField("por risco", backlog.findings.byRisk.sorted { $0.key < $1.key }.map { "\($0.key): \($0.value)" }.joined(separator: " · "))
                detailField("por rota", backlog.findings.byRoute.sorted { $0.key < $1.key }.map { "\($0.key): \($0.value)" }.joined(separator: " · "))
            }
            ForEach(backlog.findings.items) { item in
                detailCard(item.title) {
                    detailField("hash", item.findingHash)
                    detailField("source", item.source)
                    detailField("owner", item.sourceOwner)
                    detailField("gap", item.gapKind)
                    detailField("risk", item.riskLevel)
                    detailField("priority", "\(item.priorityScore)")
                    detailField("route", item.route)
                    detailField("count", "\(item.count)")
                    if let createdAt = item.createdAt {
                        detailField("criado", createdAt)
                        if let date = AtlasTime.date(createdAt) {
                            detailField("idade", AutonomosChrome.relativeAge(from: date))
                        }
                    }
                    if let rule = item.ruleId { detailField("rule id", rule) }
                    if let text = item.ruleText { detailField("rule", text) }
                }
            }
        case .budgets:
            let b = backlog.budgets
            detailCard("Limites públicos") {
                detailField("dev mode", b.devBudget.mode)
                detailField("dev work orders", "\(b.devBudget.maxConcurrentWorkOrders)")
                detailField("forge mode", b.forgeBudget.mode)
                detailField("forge obras", "\(b.forgeBudget.maxConcurrentObras)")
                detailField("wip", "\(b.wipUsed)/\(b.wipLimit)")
                detailField("dev routed", "\(b.devRouted)")
                detailField("forge routed", "\(b.forgeRouted)")
                detailField("queued", "\(b.queued)")
                detailField("budget consumed", b.budgetConsumed ? "sim" : "não")
                detailField("execution executed", b.executionExecuted ? "sim" : "não")
            }
        }
    }

    private func detailCard<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(.footnote, weight: .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
            content()
        }
        .padding(14)
        .atlasCard(cornerRadius: 12)
    }

    private func detailField(_ label: String, _ value: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(label)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .frame(width: 112, alignment: .leading)
            Text(value.isEmpty ? "—" : value)
                .font(.caption)
                .foregroundStyle(AtlasTheme.textSecondary)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
