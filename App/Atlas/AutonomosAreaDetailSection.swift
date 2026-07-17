import SwiftUI
import AtlasCore

/// Detalhe da área selecionada: métricas, placement, entregas, controles.
struct AutonomosAreaDetailSection: View {
    let area: AtlasAutonomosArea
    let model: AutonomosModel
    @Binding var control: AtlasAutonomosRunAction?
    @Binding var startRunMode: AtlasAutonomosStartRunMode?
    @Binding var showTransferSheet: Bool
    let onOpenDetail: (AutonomosDetailSheet) -> Void
    let onSelfConstructionReceipt: (SelfConstructionReceipt) -> Void

    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(area.areaName).font(AtlasFont.serif(24, .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                    Text(area.focus).font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                }
                Spacer()
                Text("tier \(area.autonomyTier)/\(area.maxTierForArea)")
                    .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.accent)
            }
            Text(area.objective).font(.footnote).foregroundStyle(AtlasTheme.textSecondary).fixedSize(horizontal: false, vertical: true)
            Divider().overlay(AtlasTheme.separatorSoft)
            HStack(spacing: 12) {
                DetailMetric(label: "ciclos", value: "\(model.cycles?.ledgerRecordCountTotal ?? 0)")
                DetailMetric(label: "tarefas", value: "\(model.backlog?.workOrders.count ?? 0)")
                DetailMetric(label: "inbox", value: "\(model.backlog?.inboxItems.count ?? 0)")
            }
            backlogDetailShortcuts
            placementSection
            deliveredSection
            if !area.ownedSystems.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    Text("SISTEMAS SOB RESPONSABILIDADE").font(AtlasFont.mono(10)).tracking(0.9).foregroundStyle(AtlasTheme.textTertiary)
                    Text(area.ownedSystems.joined(separator: " · ")).font(.caption).foregroundStyle(AtlasTheme.textSecondary)
                }
            }
            AutonomosAreaControls(
                areaName: area.areaName,
                isPaused: model.live?.isPaused == true,
                canControl: model.canControlSelectedArea,
                onResume: { control = .resume },
                onPause: { control = .pause },
                onTransfer: { showTransferSheet = true },
                onKill: { control = .kill },
                onDryRun: { startRunMode = .dryRun },
                onExecute: { startRunMode = .execute }
            )
        }
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 18).fill(AtlasTheme.surface))
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(AtlasTheme.separator, lineWidth: 1))
    }

    @ViewBuilder
    private var backlogDetailShortcuts: some View {
        if let backlog = model.backlog {
            VStack(alignment: .leading, spacing: 7) {
                Text("DETALHES PÚBLICOS")
                    .font(AtlasFont.mono(10)).tracking(0.9)
                    .foregroundStyle(AtlasTheme.textTertiary)
                HStack(spacing: 8) {
                    AutonomosDetailChipButton(label: "workOrders \(backlog.workOrders.count)", kind: .workOrders) {
                        onOpenDetail(.workOrders)
                    }
                    AutonomosDetailChipButton(label: "inbox \(backlog.inboxItems.count)", kind: .inbox) {
                        onOpenDetail(.inbox)
                    }
                    AutonomosDetailChipButton(label: "findings \(backlog.findings.returned)", kind: .findings) {
                        onOpenDetail(.findings)
                    }
                    AutonomosDetailChipButton(label: "budgets", kind: .budgets) {
                        onOpenDetail(.budgets)
                    }
                }
            }
        }
    }

    /// C13: placement é só o rótulo verificado do lock real — campo ausente
    /// permanece ausente, sem fallback visual.
    @ViewBuilder
    private var placementSection: some View {
        if let p = model.live?.runtimePlacement,
           p.host != nil || p.workspace != nil || p.repository != nil {
            VStack(alignment: .leading, spacing: 5) {
                Text("ONDE ESTÁ RODANDO").font(AtlasFont.mono(10)).tracking(0.9)
                    .foregroundStyle(AtlasTheme.textTertiary)
                HStack(spacing: 8) {
                    if let host = p.host { AutonomosChrome.tag(host) }
                    if let env = p.environment { AutonomosChrome.tag(env) }
                    if let ws = p.workspace { AutonomosChrome.tag(ws) }
                    if let repo = p.repository { AutonomosChrome.tag(repo) }
                    if let branch = p.branch { AutonomosChrome.tag(branch) }
                    if let ttl = p.leaseTTLSeconds { AutonomosChrome.tag("lease \(ttl)s") }
                }
            }
        }
    }

    /// C13 + Elite C: merge comprovado = sucesso/silêncio; delivered_total=0
    /// em auto-construção = vazio honesto (nunca “melhorou” sem ledger).
    @ViewBuilder
    private var deliveredSection: some View {
        let isSelf = isSelfConstructionArea(area)
        let deliveredTotal = model.delivered?.deliveredTotal ?? 0
        if let delivered = model.delivered, deliveredTotal > 0 {
            VStack(alignment: .leading, spacing: 6) {
                Text(isSelf ? "O ATLAS MELHOROU O PRÓPRIO APP" : "ENTREGAS COMPROVADAS · \(delivered.deliveredTotal)")
                    .font(AtlasFont.mono(10)).tracking(0.9)
                    .foregroundStyle(isSelf ? AtlasTheme.domAutonomos : AtlasTheme.accent)
                if isSelf {
                    Text("silêncio · você não foi necessário — só veto com recibo")
                        .font(AtlasFont.serifItalic(13))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                ForEach(delivered.delivered.prefix(3)) { cycle in
                    if isSelf {
                        Button {
                            onSelfConstructionReceipt(SelfConstructionReceipt(
                                cycle: cycle,
                                finding: selfConstructionFinding
                            ))
                        } label: {
                            deliveredRow(cycle)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("recibo de auto-construção, ciclo \(cycle.cycleIndex), merge \(String(cycle.mergeHash.prefix(8)))")
                    } else {
                        if let repo = area.repositoryNames.first?.nonEmpty {
                            Button {
                                openCommit(cycle.mergeHash, repo: repo)
                            } label: {
                                deliveredRow(cycle, graphHint: true)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("abrir merge \(String(cycle.mergeHash.prefix(8))) no grafo de \(repo)")
                        } else {
                            deliveredRow(cycle)
                        }
                    }
                }
            }
        } else if isSelf {
            VStack(alignment: .leading, spacing: 6) {
                Text("AUTO-CONSTRUÇÃO")
                    .font(AtlasFont.mono(10)).tracking(0.9)
                    .foregroundStyle(AtlasTheme.textTertiary)
                Text("Trabalho ainda não mergeado — aguardando o ledger. Sem entrega comprovada neste recorte.")
                    .font(AtlasFont.serifItalic(13))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .accessibilityLabel("auto-construção, aguardando ledger, nenhuma entrega comprovada")
        }
    }

    private func deliveredRow(_ cycle: AtlasAutonomosCycle, graphHint: Bool = false) -> some View {
        HStack(spacing: 8) {
            Text("ciclo \(cycle.cycleIndex)").font(.caption).foregroundStyle(AtlasTheme.textSecondary)
            Text(String(cycle.mergeHash.prefix(8))).font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .monospacedDigit()
            if graphHint {
                Image(systemName: "point.3.connected.trianglepath.dotted")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(AtlasTheme.accent)
            }
            Spacer()
            Text(cycle.recordedAt).font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
                .lineLimit(1)
        }
        .contentShape(Rectangle())
    }

    private func openCommit(_ hash: String, repo: String) {
        guard let url = URL(string: "atlas://code/\(repo)?commit=\(hash)") else { return }
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        openURL(url)
    }

    private func isSelfConstructionArea(_ area: AtlasAutonomosArea) -> Bool {
        area.repositoryNames.contains("atlas-native")
    }

    private var selfConstructionFinding: AtlasAutonomosFinding? {
        model.backlog?.findings.items.first {
            $0.source == "native_constitution_scan"
                && (($0.ruleId?.isEmpty == false) || ($0.ruleText?.isEmpty == false))
        }
    }
}

private extension String {
    var nonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
