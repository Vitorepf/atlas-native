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
                    Text("RECIBO DE AUTO-CONSTRUÇÃO")
                        .font(AtlasFont.mono(11))
                        .tracking(1.0)
                }
                .foregroundStyle(AtlasTheme.textTertiary)

                Text(receipt.title)
                    .font(AtlasFont.serif(18, .semibold))
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Regra citada")
                        .font(AtlasFont.mono(10))
                        .tracking(0.9)
                        .foregroundStyle(AtlasTheme.textTertiary)
                    Text("“\(receipt.ruleLabel)”")
                        .font(AtlasFont.serifItalic(14))
                        .foregroundStyle(AtlasTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel(spokenRuleLabel())

                VStack(alignment: .leading, spacing: 8) {
                    Text("Prova")
                        .font(AtlasFont.mono(10))
                        .tracking(0.9)
                        .foregroundStyle(AtlasTheme.textTertiary)
                    Text(receipt.proofLine)
                        .font(AtlasFont.mono(12))
                        .foregroundStyle(AtlasTheme.textPrimary)
                        .textSelection(.enabled)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AtlasTheme.surface.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
                .accessibilityElement(children: .combine)
                .accessibilityLabel(spokenProofLabel())

                if revertReceipt != nil {
                    Text("na fila · ainda não desfeito")
                        .font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasTheme.domOperacional)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 12).fill(AtlasTheme.domOperacional.opacity(0.08)))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AtlasTheme.domOperacional.opacity(0.35), lineWidth: 1))
                        .transition(reduceMotion ? .identity : .opacity)
                        .accessibilityLabel(spokenRevertQueueLabel())
                }

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
