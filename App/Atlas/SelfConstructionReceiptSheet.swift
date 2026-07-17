import SwiftUI
import AtlasCore

struct SelfConstructionReceiptSheet: View {
    let receipt: SelfConstructionReceipt
    var canRevert: Bool = false
    var revertReceipt: AtlasAutonomosCycleRevertResponse? = nil
    var onRevert: (String, String) -> Void = { _, _ in }

    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
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
                receiptSealHeader

                Text(receipt.title)
                    .font(AtlasFont.serif(18, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)

                ruleBlock
                proofBlock
                revertQueueBanner
                vetoSection
                humanSilenceLine

                Spacer(minLength: 0)
            }
            .padding(22)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: revertReceipt != nil)
        }
        .accessibilityIdentifier(A11yID.selfReceiptSheet)
        .accessibilityLabel(spokenSheetLabel())
    }
}
