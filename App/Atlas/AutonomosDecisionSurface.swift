import SwiftUI
import AtlasCore

// GOD-RESTRUCTURE: AutonomosDecisionSurface + Face/List/Detail fused

// MARK: - Surface

/// Decisions organ (WAVE-026) — one domain: published backlog → face → decide.
/// WAVE-156 density peel — host (list/detail/sections peels).
struct AutonomosDecisionSurface: View {
    let model: AutonomosModel
    let destination: AutonomosDestination
    let onNavigate: (AutonomosDestination) -> Void

    @State var pendingDecision: PendingDecision?

    var face: AutonomosDecisionFace {
        AutonomosDecisionJudgment.face(
            backlog: model.backlog,
            areaSelected: model.selectedArea != nil,
            error: model.controlError
        )
    }

    var items: [AutonomosDecisionItem] {
        AutonomosDecisionJudgment.items(from: model.backlog)
    }

    var body: some View {
        Group {
            switch destination {
            case .decisionInbox, .decisionOrder:
                detailBody
            default:
                listBody
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .accessibilityIdentifier(A11yID.autonomosDecisions)
        .sheet(item: $pendingDecision) { pending in
            AutonomosReasonSheet(
                title: AutonomosDecisionJudgment.decisionLabel(pending.decision),
                explainer: pending.explainer,
                reasonOptional: !pending.requiresRationale
            ) { actor, reason in
                Task {
                    await model.decide(
                        pending.decision,
                        findingHash: pending.item.findingHash,
                        operatorActor: actor,
                        rationale: reason,
                        riskLevel: AutonomosDecisionJudgment.riskLevel(from: pending.item.riskLevel),
                        inboxItemId: pending.item.inboxItemId,
                        workOrderId: pending.item.workOrderId
                    )
                }
            }
        }
        .task(id: model.selectedAreaID) {
            guard model.selectedAreaID != nil else { return }
            await model.refreshSelected()
        }
    }
}

// MARK: - Pending decision sheet state

struct PendingDecision: Identifiable {
    let item: AutonomosDecisionItem
    let decision: AtlasAutonomosOperatorDecision
    let requiresRationale: Bool

    var id: String { "\(item.id)|\(decision.rawValue)" }

    var explainer: String {
        "Registra \(AutonomosDecisionJudgment.decisionLabel(decision).lowercased()) sobre «\(item.title)». Não inicia execução sozinho — só o julgamento do operador."
    }
}
// MARK: - AutonomosDecisionFaceBody

extension AutonomosDecisionSurface {
    // MARK: - Sections

    func faceChrome(_ face: AutonomosDecisionFace) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            faceHeader(face)
            Spacer(minLength: 0)
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.top, 16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(AutonomosDecisionJudgment.spokenFaceChrome(face))
    }

    func faceHeader(_ face: AutonomosDecisionFace) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            AutonomosMapChrome.kicker(
                face.productWord,
                live: face.productWord == "awaiting"
            )
            AutonomosMapChrome.heroTitle(face.heroTitle, size: 28)
            Text(face.heroSub)
                .font(AtlasFont.serifItalic(15))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    func decisionRow(_ item: AutonomosDecisionItem) -> some View {
        Button {
            onNavigate(item.destination)
        } label: {
            HStack(alignment: .top, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .font(AtlasFont.serif(18, .semibold))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .multilineTextAlignment(.leading)
                    Text(AutonomosDecisionJudgment.rowMeta(item))
                        .font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
                    .atlasSans(13, .semibold)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .padding(.top, 6)
            }
            .padding(.vertical, 18)
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) {
            AutonomosMapChrome.hairline
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(AutonomosDecisionJudgment.spokenItem(item))
        .accessibilityHint("abre o julgamento desta decisão")
        .accessibilityIdentifier("\(A11yID.autonomosDecision)-\(item.id)")
    }

    func receiptLine(_ receipt: AtlasAutonomosOperatorDecisionReceipt) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Recibo · \(AutonomosDecisionJudgment.decisionLabel(receipt.decision))")
                .font(AtlasFont.serif(14, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
            Text(
                receipt.isRecordedDecisionOnly
                    ? "Decisão gravada · sem execução automática"
                    : "Recibo publicado · \(receipt.nextAllowedAction)"
            )
            .font(AtlasFont.serifItalic(13))
            .foregroundStyle(AtlasTheme.textSecondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AtlasTheme.surface.opacity(0.55))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "recibo \(AutonomosDecisionJudgment.decisionLabel(receipt.decision)), \(receipt.isRecordedDecisionOnly ? "decisão gravada sem execução" : receipt.nextAllowedAction)"
        )
    }

    func decisionMeta(
        _ decision: AtlasAutonomosOperatorDecision,
        item: AutonomosDecisionItem
    ) -> String {
        if decision == .accept,
           AutonomosDecisionJudgment.riskRequiresRationale(
            AutonomosDecisionJudgment.riskLevel(from: item.riskLevel)
           ) {
            return "exige motivo"
        }
        return ""
    }
}
// MARK: - AutonomosDecisionListBody

extension AutonomosDecisionSurface {
    // MARK: - List

    @ViewBuilder
    var listBody: some View {
        switch face {
        case .loading:
            faceChrome(face)
        case .failed:
            faceChrome(face)
        case .empty:
            faceChrome(face)
        case .items:
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    faceHeader(face)
                        .padding(.bottom, 18)
                    if let error = model.controlError, !error.isEmpty {
                        Text(error)
                            .font(AtlasFont.serifItalic(14))
                            .foregroundStyle(AtlasTheme.domOperacional)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 12)
                            .accessibilityIdentifier(A11yID.autonomosControlError)
                    }
                    if let receipt = model.lastDecisionReceipt {
                        receiptLine(receipt)
                            .padding(.bottom, 14)
                    }
                    ForEach(items) { item in
                        decisionRow(item)
                    }
                }
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 16)
                .padding(.bottom, 140)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollIndicators(.hidden)
            .accessibilityLabel(face.spokenFace)
        }
    }
}
// MARK: - AutonomosDecisionDetailBody

extension AutonomosDecisionSurface {
    // MARK: - Detail

    @ViewBuilder
    var detailBody: some View {
        if let item = AutonomosDecisionJudgment.item(
            matching: destination,
            in: model.backlog
        ) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    AutonomosMapChrome.kicker("Decisão · \(item.kind == .inbox ? "inbox" : "ordem")", live: true)
                        .padding(.bottom, 14)
                    AutonomosMapChrome.heroTitle(item.title, size: 28)
                        .padding(.bottom, 8)
                    Text(AutonomosDecisionJudgment.rowMeta(item))
                        .font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .padding(.bottom, 20)

                    if let error = model.controlError, !error.isEmpty {
                        Text(error)
                            .font(AtlasFont.serifItalic(14))
                            .foregroundStyle(AtlasTheme.domOperacional)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.bottom, 12)
                            .accessibilityIdentifier(A11yID.autonomosControlError)
                    }

                    if let receipt = model.lastDecisionReceipt,
                       receipt.findingHash == item.findingHash {
                        receiptLine(receipt)
                            .padding(.bottom, 14)
                    }

                    Text("Julgamento")
                        .font(AtlasFont.mono(10))
                        .tracking(0.8)
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .textCase(.uppercase)
                        .padding(.bottom, 10)

                    ForEach(AutonomosDecisionJudgment.allowedDecisions(for: item), id: \.id) { decision in
                        AutonomosMapNavLine(
                            title: AutonomosDecisionJudgment.decisionLabel(decision),
                            meta: decisionMeta(decision, item: item),
                            action: {
                                pendingDecision = PendingDecision(
                                    item: item,
                                    decision: decision,
                                    requiresRationale: decision == .accept
                                        && AutonomosDecisionJudgment.riskRequiresRationale(
                                            AutonomosDecisionJudgment.riskLevel(from: item.riskLevel)
                                        )
                                )
                            }
                        )
                    }

                    AutonomosMapChrome.hairline
                        .padding(.vertical, 12)
                    AutonomosMapNavLine(
                        title: "Todas as decisões",
                        meta: "",
                        action: { onNavigate(.decisions) }
                    )
                }
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 16)
                .padding(.bottom, 140)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .scrollIndicators(.hidden)
            .accessibilityIdentifier(A11yID.autonomosDecision)
            .accessibilityLabel(AutonomosDecisionJudgment.spokenItem(item))
        } else {
            // Item vanished after decide or was never published — silence, not theater.
            faceChrome(.empty)
        }
    }
}
