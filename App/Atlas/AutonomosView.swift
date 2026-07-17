import SwiftUI
import AtlasCore

/// Autônomos — área própria 24/7 (canon da obra), independente de conversa.
/// Cada valor desta tela vem do loop real: área, lock, ciclos, backlog, frota
/// global, saúde da fila e recibos governados. Nada é inferido; ausência de
/// dado é ausência na tela (C13: estado só aparece com a prova correspondente).
struct AutonomosView: View {
    @Environment(AtlasSession.self) private var session
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @State private var control: AtlasAutonomosRunAction?
    @State private var startRunMode: AtlasAutonomosStartRunMode?
    @State private var showTransferSheet = false
    @State private var detailSheet: AutonomosDetailSheet?
    @State private var nightly = NightlyProposalController.shared
    @State private var nightlyStartProposal: NightlyProposalController.ProposalPayload?
    @State private var selfConstructionReceipt: SelfConstructionReceipt?
    @State private var rhythmSampleDays: Int?

    private var model: AutonomosModel { session.autonomos }

    var body: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                content
            }
        }
        .navigationBarHidden(true)
        .task { if case .idle = model.phase { await model.load() } }
        .task { await refreshRhythmLearning() }
        .sheet(item: $control) { action in
            AutonomosControlSheet(action: action) { actor, reason in
                Task { await model.control(action, operatorActor: actor, reason: reason) }
            }
        }
        .sheet(item: $startRunMode) { mode in
            AutonomosStartRunSheet(mode: mode) { actor, reason in
                Task { await model.startRun(mode: mode, operatorActor: actor, operatorReason: reason) }
            }
        }
        .sheet(item: $nightlyStartProposal) { proposal in
            AutonomosReasonSheet(
                title: "Preparar missão noturna",
                explainer: "Ensaio (dry-run): a frota recebe a missão proposta e o recibo entra na fila; só o lease confirma execução.",
                reasonOptional: true,
                initialReason: proposal.prefilledReason
            ) { actor, reason in
                Task {
                    let previous = model.lastStartRunReceipt
                    await model.startRun(mode: .dryRun, operatorActor: actor, operatorReason: reason)
                    if model.lastStartRunReceipt != previous,
                       model.lastStartRunReceipt?.isEnqueued == true {
                        await nightly.accept(proposal)
                    }
                }
            }
        }
        .sheet(isPresented: $showTransferSheet) {
            AutonomosReasonSheet(title: "Transferir missão",
                                 explainer: "A fonte entrega a MESMA missão no próximo limite seguro; o alvo só existe quando reivindicar o lock.") { actor, reason in
                Task { await model.transfer(operatorActor: actor, reason: reason) }
            }
        }
        .sheet(item: $detailSheet) { sheet in
            AutonomosPublicDetailSheet(kind: sheet, backlog: model.backlog)
        }
        .sheet(item: $selfConstructionReceipt) { receipt in
            SelfConstructionReceiptSheet(
                receipt: receipt,
                canRevert: canRevertSelfConstruction(receipt),
                revertReceipt: revertReceipt(for: receipt)
            ) { actor, reason in
                Task {
                    await model.revertCycle(
                        cycle: String(receipt.cycle.cycleIndex),
                        operatorActor: actor,
                        reason: reason
                    )
                }
            }
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(AtlasTheme.surface))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("Autônomos")
                    .font(AtlasFont.serif(21, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                Text("ÁREA PRÓPRIA · 24/7")
                    .font(AtlasFont.mono(10)).tracking(1.2)
                    .foregroundStyle(AtlasTheme.accent)
                if session.auditModeEnabled {
                    Text("MODO AUDITORIA")
                        .font(AtlasFont.mono(9)).tracking(1.0)
                        .foregroundStyle(AtlasTheme.domOperacional)
                }
            }
            Spacer()
            Button { Task { await model.refreshSelected() } } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AtlasTheme.textSecondary)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(AtlasTheme.surface))
            }
            .disabled(model.selectedArea == nil)
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, 8)
    }

    @ViewBuilder
    private var content: some View {
        switch model.phase {
        case .idle, .loading:
            if let proposal = nightly.pendingProposal {
                nightlyProposal(proposal)
                    .padding(.horizontal, AtlasTheme.Space.screen)
                    .padding(.top, 10)
            }
            rhythmLearningLine
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 10)
            Spacer()
            VStack(spacing: 14) {
                ProgressView().tint(AtlasTheme.accent)
                Text("consultando a frota…")
                    .font(AtlasFont.serifItalic(15)).foregroundStyle(AtlasTheme.textTertiary)
            }
            Spacer()
        case .failed(let message):
            if let proposal = nightly.pendingProposal {
                nightlyProposal(proposal)
                    .padding(.horizontal, AtlasTheme.Space.screen)
                    .padding(.top, 10)
            }
            rhythmLearningLine
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 10)
            Spacer()
            VStack(spacing: 14) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.title2).foregroundStyle(AtlasTheme.domOperacional)
                Text("A frota está fora de alcance.")
                    .font(AtlasFont.serif(20, .semibold)).foregroundStyle(AtlasTheme.textPrimary)
                Text(message).font(.footnote).foregroundStyle(AtlasTheme.textSecondary)
                    .multilineTextAlignment(.center)
                Button("Tentar de novo") { Task { await model.load() } }
                    .buttonStyle(AutonomosPrimaryButtonStyle())
            }
            .padding(32)
            Spacer()
        case .loaded:
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    if let proposal = nightly.pendingProposal {
                        nightlyProposal(proposal)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    rhythmLearningLine
                    if let fleet = model.fleet { fleetSummary(fleet) }
                    nextDigestSection
                    operationDigest
                    awaitingYouSection
                    areaPicker
                    if let area = model.selectedArea { areaDetail(area) }
                    if let receipt = model.lastStartRunReceipt, receipt.isEnqueued {
                        infoLine("Novo ciclo NA FILA — ainda não iniciado. A execução só é real quando o lease aparecer no vivo.")
                    }
                    if let transfer = model.lastTransferReceipt { transferStatus(transfer) }
                    if let receipt = model.lastControlReceipt { controlReceipt(receipt) }
                    if let fleet = model.fleet { fleetSection(fleet) }
                    if let health = model.taskHealth { taskHealthSection(health) }
                    if let history = model.fleetHistory, !history.events.isEmpty {
                        historySection(history)
                    }
                    if let error = model.controlError { errorCard(error) }
                }
                .padding(.horizontal, AtlasTheme.Space.screen).padding(.top, 10).padding(.bottom, 32)
            }
            .refreshable {
                await model.load()
                await refreshRhythmLearning()
            }
            .scrollIndicators(.hidden)
        }
    }

    private func nightlyProposal(_ proposal: NightlyProposalController.ProposalPayload) -> some View {
        NightlyProposalCard(
            proposal: proposal,
            onAccept: { nightlyStartProposal = proposal },
            onDismiss: { nightly.dismissProposal() },
            onMute: { nightly.muteProposal(days: $0) }
        )
    }

    @ViewBuilder
    private var rhythmLearningLine: some View {
        if let sampleDays = rhythmSampleDays, sampleDays < 4 {
            Text("aprendendo seu ritmo · dia \(max(1, sampleDays)) de 4")
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityLabel("aprendendo seu ritmo, dia \(max(1, sampleDays)) de 4")
        }
    }

    private func refreshRhythmLearning() async {
        let windows = await AtlasSession.rhythm.windows(minimumDays: 4)
        rhythmSampleDays = windows.sampleDays
    }

    // MARK: - Próximo resumo (M09)

    @ViewBuilder
    private var nextDigestSection: some View {
        if let digest = model.digest, shouldShowDigest(digest) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    sectionCaption("PRÓXIMO RESUMO")
                    Spacer()
                    Text(digest.nextDigestAt ?? "sem digest agendado")
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(digest.nextDigestAt == nil ? AtlasTheme.textTertiary : AtlasTheme.accent)
                        .lineLimit(1)
                }
                if let next = digest.nextDigestAt {
                    Text(next)
                        .font(AtlasFont.serifItalic(15))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .textSelection(.enabled)
                } else {
                    Text(digest.schedule.reason?.nonEmpty ?? "sem digest agendado")
                        .font(AtlasFont.serifItalic(15))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if hasLastDigest(digest) {
                    HStack(spacing: 8) {
                        if digest.last.counts.delivered > 0 {
                            digestChip("\(digest.last.counts.delivered)", "entregas")
                        }
                        if digest.last.counts.risks > 0 {
                            digestChip("\(digest.last.counts.risks)", "riscos")
                        }
                        if digest.last.counts.pendingDecisions > 0 {
                            digestChip("\(digest.last.counts.pendingDecisions)", "decisões")
                        }
                    }
                    if let delivered = digest.last.delivered.first {
                        tag("merge \(String(delivered.mergeHash.prefix(8)))")
                    }
                    if let risk = digest.last.risks.first {
                        Text(risk.title?.nonEmpty ?? risk.reason?.nonEmpty ?? risk.severity)
                            .font(.caption)
                            .foregroundStyle(AtlasTheme.textSecondary)
                            .lineLimit(2)
                    }
                    if let decision = digest.last.pendingDecisions.first {
                        Text(decision.title)
                            .font(.caption)
                            .foregroundStyle(AtlasTheme.textSecondary)
                            .lineLimit(2)
                    }
                }
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 14).fill(AtlasTheme.surface))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(AtlasTheme.goldBorder, lineWidth: 1))
        }
    }

    private func shouldShowDigest(_ digest: AtlasAutonomosDigestResponse) -> Bool {
        digest.nextDigestAt != nil
            || digest.schedule.available
            || digest.schedule.reason?.nonEmpty != nil
            || hasLastDigest(digest)
    }

    private func hasLastDigest(_ digest: AtlasAutonomosDigestResponse) -> Bool {
        digest.last.counts.delivered > 0
            || digest.last.counts.risks > 0
            || digest.last.counts.pendingDecisions > 0
            || !digest.last.delivered.isEmpty
            || !digest.last.risks.isEmpty
            || !digest.last.pendingDecisions.isEmpty
    }

    // MARK: - Resumo da operação (C20: digest por agregação de dado REAL)

    /// O "resumo ao acordar" da cena 06 — mas honesto: agrega SÓ o que o
    /// servidor já publica (entregas comprovadas, pendências por risco,
    /// decisões aguardando, incidente). Sem `next_digest_at` inventado — o
    /// agendamento formal fica no pedido C20 até o servidor publicar o horário.
    @ViewBuilder
    private var operationDigest: some View {
        let delivered = model.delivered?.deliveredTotal ?? 0
        let pending = model.backlog?.workOrders.count ?? 0
        let inbox = model.backlog?.inboxItems.count ?? 0
        let incident = model.taskHealth?.incidents.present == true
        let hasSignal = delivered > 0 || pending > 0 || inbox > 0 || incident
        if hasSignal {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    sectionCaption("RESUMO DA OPERAÇÃO")
                    Spacer()
                    Text(incident ? "requer você" : "por exceção")
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(incident ? AtlasTheme.domOperacional : AtlasTheme.domAutonomos)
                }
                // A frase-título: o estado da frota em uma linha honesta.
                Text(digestHeadline(delivered: delivered, pending: pending, incident: incident))
                    .font(AtlasFont.serifItalic(15)).foregroundStyle(AtlasTheme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 8) {
                    if delivered > 0 { digestChip("\(delivered)", "entregues · merge") }
                    if pending > 0 { digestChip("\(pending)", "tarefas na fila") }
                    if inbox > 0 { digestChip("\(inbox)", "decisões aguardam") }
                }
                if let oldest = oldestBacklogCreatedAt() {
                    Text("item mais antigo · \(Self.relativeAge(from: oldest))")
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.domOperacional)
                        .monospacedDigit()
                }
                if let byRisk = model.backlog?.findings.byRisk, !byRisk.isEmpty {
                    HStack(spacing: 6) {
                        ForEach(byRisk.sorted(by: { $0.value > $1.value }), id: \.key) { risk, n in
                            tag("\(risk): \(n)")
                        }
                    }
                }
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 14).fill(AtlasTheme.surface))
            .overlay(RoundedRectangle(cornerRadius: 14)
                .stroke(incident ? AtlasTheme.domOperacional.opacity(0.4) : AtlasTheme.goldBorder, lineWidth: 1))
        }
    }

    private func digestHeadline(delivered: Int, pending: Int, incident: Bool) -> String {
        if incident { return "Um incidente aguarda sua decisão; o resto da frota segue por exceção." }
        if delivered > 0 && pending == 0 { return "\(delivered) entrega\(delivered == 1 ? "" : "s") comprovada\(delivered == 1 ? "" : "s") — nada pendente para você." }
        if delivered > 0 { return "\(delivered) entregue\(delivered == 1 ? "" : "s"), \(pending) ainda na fila — trabalho saudável em curso." }
        return "\(pending) tarefa\(pending == 1 ? "" : "s") na fila; nenhuma entrega comprovada ainda nesta janela."
    }

    private func digestChip(_ value: String, _ label: String) -> some View {
        HStack(spacing: 5) {
            Text(value).font(AtlasFont.mono(14)).foregroundStyle(AtlasTheme.accent)
                .monospacedDigit()
                .contentTransition(.numericText())
            Text(label).font(.caption2).foregroundStyle(AtlasTheme.textTertiary)
        }
        .padding(.horizontal, 9).padding(.vertical, 6)
        .background(Capsule().fill(AtlasTheme.bgRecessed))
    }

    private func oldestBacklogCreatedAt() -> Date? {
        guard let backlog = model.backlog else { return nil }
        let values = backlog.workOrders.compactMap { AtlasTime.date($0.createdAt) }
            + backlog.inboxItems.compactMap { AtlasTime.date($0.createdAt) }
            + backlog.findings.items.compactMap { AtlasTime.date($0.createdAt) }
        return values.min()
    }

    // MARK: - Aguarda operador (M139)

    @ViewBuilder
    private var awaitingYouSection: some View {
        let inbox = model.backlog?.inboxItems.filter(\.decisionRequired) ?? []
        let workOrders = model.backlog?.workOrders.filter(\.operatorDecisionRequired) ?? []
        let count = inbox.count + workOrders.count
        if count > 0 {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    sectionCaption("AGUARDANDO VOCÊ")
                    Spacer()
                    Text("\(count)")
                        .font(AtlasFont.mono(13))
                        .foregroundStyle(AtlasTheme.domOperacional)
                        .contentTransition(.numericText())
                }
                Text("Há decisão pública pendente; nada aqui afirma execução antes do recibo do owner.")
                    .font(AtlasFont.serifItalic(14))
                    .foregroundStyle(AtlasTheme.textSecondary)
                HStack(spacing: 8) {
                    if !inbox.isEmpty {
                        detailButton("inbox \(inbox.count)", .inbox)
                    }
                    if !workOrders.isEmpty {
                        detailButton("ordens \(workOrders.count)", .workOrders)
                    }
                    if model.backlog?.findings.returned ?? 0 > 0 {
                        detailButton("findings", .findings)
                    }
                    detailButton("budgets", .budgets)
                }
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 14).fill(AtlasTheme.domOperacional.opacity(0.08)))
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(AtlasTheme.domOperacional.opacity(0.38), lineWidth: 1))
            .accessibilityElement(children: .contain)
            .accessibilityLabel("aguardando você, \(count) decisões")
            .accessibilityIdentifier(A11yID.autonomosAwaitingYou)
        }
    }

    private func detailButton(_ label: String, _ kind: AutonomosDetailSheet) -> some View {
        Button { detailSheet = kind } label: {
            Text(label)
                .font(AtlasFont.mono(10))
                .foregroundStyle(AtlasTheme.textPrimary)
                .padding(.horizontal, 9)
                .padding(.vertical, 6)
                .background(Capsule().fill(AtlasTheme.surfaceHi))
                .overlay(Capsule().stroke(AtlasTheme.separator, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("abrir detalhes de \(label)")
        .accessibilityIdentifier(A11yID.autonomosDetailButton(kind.id))
    }

    // MARK: - Frota global (C13: agentes reais, nunca contagem de áreas)

    private func fleetSummary(_ fleet: AtlasAutonomosFleetResponse) -> some View {
        HStack(spacing: 8) {
            FleetMetric(value: "\(fleet.agents.count)", label: "agentes registrados")
            FleetMetric(value: "\(fleet.agents.filter(\.alive).count)", label: "vivos agora")
            FleetMetric(value: "\(fleet.activeCount)", label: "ativos")
        }
    }

    private func fleetSection(_ fleet: AtlasAutonomosFleetResponse) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionCaption("FROTA GLOBAL")
            ForEach(fleet.agents) { agent in
                VStack(alignment: .leading, spacing: 5) {
                    HStack(spacing: 8) {
                        Circle().fill(agent.alive ? AtlasTheme.domAutonomos : AtlasTheme.textTertiary)
                            .frame(width: 7, height: 7)
                        Text(agent.label).font(.system(.footnote, weight: .semibold))
                            .foregroundStyle(AtlasTheme.textPrimary)
                        Spacer()
                        Text(agent.status).font(AtlasFont.mono(10)).foregroundStyle(AtlasTheme.textTertiary)
                    }
                    HStack(spacing: 10) {
                        if let up = agent.uptimeSeconds { tag("↑ " + Self.uptime(up)) }
                        if !agent.pids.isEmpty { tag("\(agent.pids.count) pid\(agent.pids.count == 1 ? "" : "s")") }
                        if let spent = agent.spentUsd { tag(String(format: "US$ %.2f", spent)) }
                        tag(agent.desired ? "desejado" : "não desejado")
                        tag(agent.authorized ? "autorizado" : "não autorizado")
                    }
                    if session.auditModeEnabled {
                        HStack(spacing: 6) {
                            tag(agent.account)
                            tag(agent.kind)
                            if let ttl = agent.ttlRemainingSeconds { tag("ttl \(ttl)s") }
                            if let budget = agent.budgetLimitUsd { tag(String(format: "limite %.2f", budget)) }
                            if let target = agent.targetRef?.nonEmpty { tag(target) }
                        }
                        if let reason = agent.reason?.nonEmpty {
                            Text(reason)
                                .font(.caption2)
                                .foregroundStyle(AtlasTheme.textTertiary)
                                .lineLimit(2)
                        }
                    }
                }
                .padding(12)
                .atlasCard(cornerRadius: 12)
            }
        }
    }

    /// C13: saúde da fila do músculo externo — contagens verificáveis, nunca
    /// "plano/progresso"; alerta só quando o servidor declara incidente.
    private func taskHealthSection(_ health: AtlasAutonomosTaskHealthResponse) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionCaption("SAÚDE DA FILA")
            HStack(spacing: 8) {
                FleetMetric(value: "\(health.tasks.servableNow)", label: "servíveis agora")
                FleetMetric(value: "\(health.tasks.claimed)", label: "reivindicadas")
                FleetMetric(value: "\(health.tasks.blocked)", label: "bloqueadas")
                FleetMetric(value: "\(health.leases.active)", label: "leases ativos")
            }
            HStack(spacing: 8) {
                FleetMetric(value: "\(health.tasks.completed)", label: "completas")
                FleetMetric(value: "\(health.tasks.recoverable)", label: "recuperáveis")
            }
            if health.incidents.present {
                VStack(alignment: .leading, spacing: 6) {
                    Text("INCIDENTE").font(AtlasFont.mono(10)).tracking(1.1)
                        .foregroundStyle(AtlasTheme.domOperacional)
                    Text(health.incidents.flags.joined(separator: " · "))
                        .font(.caption).foregroundStyle(AtlasTheme.textSecondary)
                    Text(health.operating.recommendedAction)
                        .font(AtlasFont.serifItalic(13)).foregroundStyle(AtlasTheme.textPrimary)
                }
                .padding(12).frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: 12).fill(AtlasTheme.domOperacional.opacity(0.08)))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AtlasTheme.domOperacional.opacity(0.4), lineWidth: 1))
            }
        }
    }

    private func historySection(_ history: AtlasAutonomosFleetHistoryResponse) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // A legenda conta o total: mostrar 6 de N sem dizer N faz o operador
            // ler "6" como "tudo". Nada cortado em silêncio.
            sectionCaption(history.events.count > 6
                           ? "HISTÓRICO DA FROTA · 6 DE \(history.events.count)"
                           : "HISTÓRICO DA FROTA")
            ForEach(Array(history.events.prefix(6).enumerated()), id: \.element.id) { index, event in
                HStack(alignment: .top, spacing: 10) {
                    VStack(spacing: 0) {
                        Circle()
                            .fill(index == 0 ? AtlasTheme.accent : AtlasTheme.accent.opacity(0.35))
                            .frame(width: 7, height: 7)
                            .padding(.top, 5)
                        if index < min(history.events.count, 6) - 1 {
                            Rectangle()
                                .fill(AtlasTheme.accent.opacity(0.18))
                                .frame(width: 1.5, height: 34)
                        }
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(event.event)
                            .font(.system(.caption, weight: .semibold))
                            .foregroundStyle(AtlasTheme.textPrimary)
                        HStack(spacing: 6) {
                            tag(event.agentKey)
                            if let by = event.by?.nonEmpty { tag(by) }
                            if let account = event.account?.nonEmpty { tag(account) }
                            if let pid = event.pid { tag("pid \(pid)") }
                            if let duration = event.durationSeconds { tag(Self.uptime(duration)) }
                        }
                        if let reason = event.reason?.nonEmpty {
                            Text(reason)
                                .font(.caption2)
                                .foregroundStyle(AtlasTheme.textSecondary)
                                .lineLimit(2)
                        }
                        Text(event.at)
                            .font(AtlasFont.mono(9))
                            .foregroundStyle(AtlasTheme.textTertiary)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - Instâncias (áreas)

    private var areaPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            sectionCaption("INSTÂNCIAS")
            ForEach(model.areas) { area in
                Button {
                    Task { await model.selectArea(area.id) }
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
                    .background(RoundedRectangle(cornerRadius: 12).fill(area.id == model.selectedAreaID ? AtlasTheme.surfaceHi : AtlasTheme.surface))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(area.id == model.selectedAreaID ? AtlasTheme.goldBorder : AtlasTheme.separatorSoft, lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func areaDetail(_ area: AtlasAutonomosArea) -> some View {
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
            deliveredSection(for: area)
            if !area.ownedSystems.isEmpty {
                VStack(alignment: .leading, spacing: 5) {
                    Text("SISTEMAS SOB RESPONSABILIDADE").font(AtlasFont.mono(10)).tracking(0.9).foregroundStyle(AtlasTheme.textTertiary)
                    Text(area.ownedSystems.joined(separator: " · ")).font(.caption).foregroundStyle(AtlasTheme.textSecondary)
                }
            }
            controls(for: area)
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
                    detailButton("workOrders \(backlog.workOrders.count)", .workOrders)
                    detailButton("inbox \(backlog.inboxItems.count)", .inbox)
                    detailButton("findings \(backlog.findings.returned)", .findings)
                    detailButton("budgets", .budgets)
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
                    if let host = p.host { tag(host) }
                    if let env = p.environment { tag(env) }
                    if let ws = p.workspace { tag(ws) }
                    if let repo = p.repository { tag(repo) }
                    if let branch = p.branch { tag(branch) }
                    if let ttl = p.leaseTTLSeconds { tag("lease \(ttl)s") }
                }
            }
        }
    }

    /// C13: somente ciclos com merge comprovado (outcome=merged + hash real).
    @ViewBuilder
    private func deliveredSection(for area: AtlasAutonomosArea) -> some View {
        if let delivered = model.delivered, delivered.deliveredTotal > 0 {
            let isSelf = isSelfConstructionArea(area)
            VStack(alignment: .leading, spacing: 6) {
                Text(isSelf ? "O ATLAS MELHOROU O PRÓPRIO APP" : "ENTREGAS COMPROVADAS · \(delivered.deliveredTotal)")
                    .font(AtlasFont.mono(10)).tracking(0.9)
                    .foregroundStyle(isSelf ? AtlasTheme.domAutonomos : AtlasTheme.accent)
                ForEach(delivered.delivered.prefix(3)) { cycle in
                    if isSelf {
                        Button {
                            selfConstructionReceipt = SelfConstructionReceipt(
                                cycle: cycle,
                                finding: selfConstructionFinding
                            )
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

    private func canRevertSelfConstruction(_ receipt: SelfConstructionReceipt) -> Bool {
        model.canControlSelectedArea && receipt.cycle.mergeHash.nonEmpty != nil
    }

    private func revertReceipt(for receipt: SelfConstructionReceipt) -> AtlasAutonomosCycleRevertResponse? {
        guard let revert = model.lastRevertReceipt else { return nil }
        guard revert.revertOf.cycleIndex == receipt.cycle.cycleIndex,
              revert.revertOf.mergeHash == receipt.cycle.mergeHash else { return nil }
        return revert
    }

    /// C13: disponibilidade vem de canControlSelectedArea (POSTs existem e são
    /// governados) — nunca de live.readOnly, que descreve apenas o GET.
    private func controls(for area: AtlasAutonomosArea) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                if model.live?.isPaused == true {
                    Button("Retomar") { control = .resume }.buttonStyle(AutonomosPrimaryButtonStyle())
                } else {
                    Button("Pausar") { control = .pause }.buttonStyle(AutonomosSecondaryButtonStyle())
                }
                Button("Transferir") { showTransferSheet = true }.buttonStyle(AutonomosSecondaryButtonStyle())
                Button("Encerrar") { control = .kill }.buttonStyle(AutonomosDestructiveButtonStyle())
            }
            HStack(spacing: 8) {
                Button("Novo ciclo · ensaio") { startRunMode = .dryRun }
                    .buttonStyle(AutonomosPrimaryButtonStyle())
                Button("Executar de verdade") { startRunMode = .execute }
                    .buttonStyle(AutonomosSecondaryButtonStyle())
            }
        }
        .disabled(!model.canControlSelectedArea)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("controles da instância \(area.areaName)")
    }

    /// C13: estados do handoff LITERAIS; host alvo só depois de target_claimed.
    private func transferStatus(_ transfer: AtlasAutonomosTransferResponse) -> some View {
        HStack(spacing: 10) {
            Text(transfer.handoff.status)
                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.accent)
            if let note = transfer.note {
                Text(note).font(.caption).foregroundStyle(AtlasTheme.textSecondary).lineLimit(2)
            }
            Spacer()
            Button { Task { await model.refreshTransferStatus() } } label: {
                Image(systemName: "arrow.clockwise").font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AtlasTheme.textSecondary)
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(AtlasTheme.goldVeil))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AtlasTheme.goldBorder, lineWidth: 1))
    }

    private func controlReceipt(_ receipt: AtlasAutonomosRunControlResponse) -> some View {
        Text(receipt.note)
            .font(.footnote).foregroundStyle(AtlasTheme.textSecondary)
            .padding(12).frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 12).fill(AtlasTheme.domAutonomos.opacity(0.1)))
    }

    private func infoLine(_ text: String) -> some View {
        Text(text)
            .font(.footnote).foregroundStyle(AtlasTheme.textSecondary)
            .padding(12).frame(maxWidth: .infinity, alignment: .leading)
            .atlasCard(cornerRadius: 12)
    }

    private func errorCard(_ message: String) -> some View {
        Text(message).font(.footnote).foregroundStyle(AtlasTheme.domOperacional)
            .padding(12).frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 12).fill(AtlasTheme.domOperacional.opacity(0.1)))
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

    private func sectionCaption(_ t: String) -> some View {
        Text(t)
            .font(.system(.caption, weight: .semibold)).tracking(1.2)
            .foregroundStyle(AtlasTheme.textTertiary)
    }

    private func tag(_ t: String) -> some View {
        Text(t)
            .font(AtlasFont.mono(9)).foregroundStyle(AtlasTheme.textTertiary)
            .padding(.horizontal, 7).padding(.vertical, 3)
            .background(Capsule().stroke(AtlasTheme.separatorSoft, lineWidth: 1))
            .lineLimit(1)
    }

    private static func uptime(_ seconds: Int) -> String {
        if seconds >= 86_400 { return "\(seconds / 86_400)d \((seconds % 86_400) / 3600)h" }
        if seconds >= 3600 { return "\(seconds / 3600)h \((seconds % 3600) / 60)m" }
        return "\(seconds / 60)m"
    }

    fileprivate static func relativeAge(from date: Date, now: Date = Date()) -> String {
        let seconds = max(0, Int(now.timeIntervalSince(date)))
        let days = seconds / 86_400
        if days > 0 { return days == 1 ? "1 dia" : "\(days) dias" }
        let hours = seconds / 3_600
        if hours > 0 { return "\(hours)h" }
        return "\(max(1, seconds / 60))min"
    }
}

extension AtlasAutonomosStartRunMode {
    var actionLabel: String { self == .execute ? "Executar de verdade" : "Novo ciclo · ensaio" }
}

private struct FleetMetric: View {
    let value: String; let label: String
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(value).font(AtlasFont.mono(18)).foregroundStyle(AtlasTheme.textPrimary)
                .contentTransition(.numericText())
            Text(label).font(.caption2).foregroundStyle(AtlasTheme.textTertiary).lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading).padding(11)
        .atlasCard(cornerRadius: 12)
    }
}

private struct DetailMetric: View {
    let label: String; let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value).font(AtlasFont.mono(15)).foregroundStyle(AtlasTheme.textPrimary)
                .contentTransition(.numericText())
            Text(label).font(.caption2).foregroundStyle(AtlasTheme.textTertiary)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}

private enum AutonomosDetailSheet: String, Identifiable {
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

private struct AutonomosPublicDetailSheet: View {
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
                            detailField("idade", AutonomosView.relativeAge(from: date))
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
                            detailField("idade", AutonomosView.relativeAge(from: date))
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
                            detailField("idade", AutonomosView.relativeAge(from: date))
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

private struct AutonomosControlSheet: View {
    let action: AtlasAutonomosRunAction
    let onConfirm: (String, String) -> Void

    var body: some View {
        AutonomosReasonSheet(title: label, explainer: "Ação governada — operador e motivo ficam no recibo auditável.", onConfirm: onConfirm)
    }

    private var label: String {
        switch action { case .pause: return "Pausar"; case .resume: return "Retomar"; case .kill: return "Encerrar"; case .clearKill: return "Liberar encerramento" }
    }
}

/// C13: novo ciclo é governado — ensaio é o default; executar exige motivo.
private struct AutonomosStartRunSheet: View {
    let mode: AtlasAutonomosStartRunMode
    let onConfirm: (String, String) -> Void

    var body: some View {
        AutonomosReasonSheet(
            title: mode.actionLabel,
            explainer: mode == .execute
                ? "Execução real: motivo auditável obrigatório. O recibo entra NA FILA; só o lease confirma execução."
                : "Ensaio (dry-run): percorre o ciclo sem mutação. O recibo entra na fila.",
            reasonOptional: mode == .dryRun,
            onConfirm: onConfirm
        )
    }
}

/// Folha padrão de governança: quem autoriza + motivo auditável.
private struct AutonomosReasonSheet: View {
    let title: String
    let explainer: String
    var reasonOptional: Bool = false
    let onConfirm: (String, String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var actor = ""
    @State private var reason = ""

    init(
        title: String,
        explainer: String,
        reasonOptional: Bool = false,
        initialReason: String = "",
        onConfirm: @escaping (String, String) -> Void
    ) {
        self.title = title
        self.explainer = explainer
        self.reasonOptional = reasonOptional
        self.onConfirm = onConfirm
        _reason = State(initialValue: initialReason)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Ação governada") {
                    Text(title)
                    Text(explainer).font(.footnote).foregroundStyle(.secondary)
                }
                Section("Operador") { TextField("Quem autoriza", text: $actor) }
                Section(reasonOptional ? "Motivo (opcional no ensaio)" : "Motivo") {
                    TextField("Motivo auditável", text: $reason, axis: .vertical).lineLimit(3...6)
                }
            }
            .navigationTitle("Confirmar ação")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Confirmar") { onConfirm(actor, reason); dismiss() }
                        .disabled(actor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                  || (!reasonOptional && reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty))
                }
            }
        }
    }
}

private struct AutonomosPrimaryButtonStyle: ButtonStyle { func makeBody(configuration: Configuration) -> some View { configuration.label.font(.system(.footnote, weight: .semibold)).foregroundStyle(AtlasTheme.bg).padding(.horizontal, 14).padding(.vertical, 9).background(Capsule().fill(AtlasTheme.accent.opacity(configuration.isPressed ? 0.72 : 1))).scaleEffect(configuration.isPressed ? 0.97 : 1) } }
private struct AutonomosSecondaryButtonStyle: ButtonStyle { func makeBody(configuration: Configuration) -> some View { configuration.label.font(.system(.footnote, weight: .semibold)).foregroundStyle(AtlasTheme.textPrimary).padding(.horizontal, 14).padding(.vertical, 9).background(Capsule().fill(AtlasTheme.surfaceHi)).overlay(Capsule().stroke(AtlasTheme.separator, lineWidth: 1)) } }
private struct AutonomosDestructiveButtonStyle: ButtonStyle { func makeBody(configuration: Configuration) -> some View { configuration.label.font(.system(.footnote, weight: .semibold)).foregroundStyle(AtlasTheme.domOperacional).padding(.horizontal, 14).padding(.vertical, 9).background(Capsule().fill(AtlasTheme.domOperacional.opacity(0.1))).overlay(Capsule().stroke(AtlasTheme.domOperacional.opacity(0.45), lineWidth: 1)) } }

private extension String {
    var nonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
