import SwiftUI
import AtlasCore

// WAVE-156 density peel — decision detail body

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
