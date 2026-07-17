import SwiftUI
import AtlasCore

/// Lista de instâncias (áreas) — seleção dispara `selectArea` no model.
struct AutonomosAreaPicker: View {
    let areas: [AtlasAutonomosArea]
    let selectedAreaID: String?
    let onSelect: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AutonomosChrome.sectionCaption("INSTÂNCIAS")
            ForEach(areas) { area in
                Button {
                    onSelect(area.id)
                } label: {
                    HStack(spacing: 10) {
                        Circle().fill(areaStateColor(area)).frame(width: 8, height: 8)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(area.areaName).font(.system(.footnote, weight: .semibold))
                                .foregroundStyle(AtlasTheme.textPrimary)
                            Text(area.objective).font(.caption).foregroundStyle(AtlasTheme.textTertiary)
                                .lineLimit(1)
                        }
                        Spacer()
                        Text(areaStateLabel(area)).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textTertiary)
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(area.id == selectedAreaID ? AtlasTheme.surfaceHi : AtlasTheme.surface))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(area.id == selectedAreaID ? AtlasTheme.goldBorder : AtlasTheme.separatorSoft, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // C13: fase canônica do Core (terminated > paused > running > idle) —
    // a View não relê nem reinterpreta run_state cru.
    private func areaStateLabel(_ area: AtlasAutonomosArea) -> String {
        switch area.loopStatus.phase {
        case .terminated: return "encerrada"
        case .paused: return "pausada"
        case .running: return "executando"
        case .idle: return "sem lease"
        }
    }

    private func areaStateColor(_ area: AtlasAutonomosArea) -> Color {
        switch area.loopStatus.phase {
        case .terminated: return AtlasTheme.domOperacional
        case .paused: return AtlasTheme.accent
        case .running: return AtlasTheme.domAutonomos
        case .idle: return AtlasTheme.textTertiary
        }
    }
}

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

    /// C13: somente ciclos com merge comprovado (outcome=merged + hash real).
    @ViewBuilder
    private var deliveredSection: some View {
        if let delivered = model.delivered, delivered.deliveredTotal > 0 {
            let isSelf = isSelfConstructionArea(area)
            VStack(alignment: .leading, spacing: 6) {
                Text(isSelf ? "O ATLAS MELHOROU O PRÓPRIO APP" : "ENTREGAS COMPROVADAS · \(delivered.deliveredTotal)")
                    .font(AtlasFont.mono(10)).tracking(0.9)
                    .foregroundStyle(isSelf ? AtlasTheme.domAutonomos : AtlasTheme.accent)
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

/// C13: disponibilidade vem de canControlSelectedArea (POSTs existem e são
/// governados) — nunca de live.readOnly, que descreve apenas o GET.
struct AutonomosAreaControls: View {
    let areaName: String
    let isPaused: Bool
    let canControl: Bool
    let onResume: () -> Void
    let onPause: () -> Void
    let onTransfer: () -> Void
    let onKill: () -> Void
    let onDryRun: () -> Void
    let onExecute: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                if isPaused {
                    Button("Retomar", action: onResume).buttonStyle(AutonomosPrimaryButtonStyle())
                } else {
                    Button("Pausar", action: onPause).buttonStyle(AutonomosSecondaryButtonStyle())
                }
                Button("Transferir", action: onTransfer).buttonStyle(AutonomosSecondaryButtonStyle())
                Button("Encerrar", action: onKill).buttonStyle(AutonomosDestructiveButtonStyle())
            }
            HStack(spacing: 8) {
                Button("Novo ciclo · ensaio", action: onDryRun)
                    .buttonStyle(AutonomosPrimaryButtonStyle())
                Button("Executar de verdade", action: onExecute)
                    .buttonStyle(AutonomosSecondaryButtonStyle())
            }
        }
        .disabled(!canControl)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("controles da instância \(areaName)")
    }
}

private extension String {
    var nonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
