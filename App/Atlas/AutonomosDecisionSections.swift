import SwiftUI
import AtlasCore

// WAVE-156 density peel — decision sections (chrome/row/receipt)

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
