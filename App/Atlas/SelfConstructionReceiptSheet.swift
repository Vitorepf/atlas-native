import SwiftUI
import AtlasCore

struct SelfConstructionReceiptSheet: View {
    let receipt: SelfConstructionReceipt
    var canRevert: Bool = false
    var revertReceipt: AtlasAutonomosCycleRevertResponse? = nil
    var onRevert: (String, String) -> Void = { _, _ in }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State var actor = ""
    @State var reason = ""

    var canSubmitRevert: Bool {
        !actor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 7) {
                    Image(systemName: "checkmark.seal")
                        .font(.system(size: 11, weight: .bold))
                        .accessibilityHidden(true)
                    Text("RECIBO DE AUTO-CONSTRUÇÃO")
                        .font(AtlasFont.mono(11))
                        .tracking(1.0)
                        .accessibilityHidden(true)
                }
                .foregroundStyle(AtlasTheme.textTertiary)

                Text(receipt.title)
                    .font(AtlasFont.serif(18, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)

                ruleBlock
                proofBlock
                revertQueueBanner
                vetoSection

                if receipt.hasMergeProof {
                    Text("você não foi necessário — entrega sem portão")
                        .font(AtlasFont.serifItalic(13))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .accessibilityLabel(spokenHumanSilenceLabel())
                }

                Spacer(minLength: 0)
            }
            .padding(22)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: revertReceipt != nil)
        }
        .accessibilityIdentifier(A11yID.selfReceiptSheet)
        .accessibilityLabel(spokenSheetLabel())
    }
}
