import SwiftUI
import AtlasCore

struct SelfConstructionReceipt: Identifiable {
    let cycle: AtlasAutonomosCycle
    let finding: AtlasAutonomosFinding?

    var id: String { cycle.id }
    var title: String { finding?.title.nonEmpty ?? "O Atlas melhorou o próprio app" }
    var ruleLabel: String {
        if let ruleId = finding?.ruleId?.nonEmpty, let text = finding?.ruleText?.nonEmpty {
            return "\(ruleId) — \(text)"
        }
        if let ruleId = finding?.ruleId?.nonEmpty { return "\(ruleId) — regra publicada sem texto neste recorte." }
        return "Regra não publicada no recorte deste recibo."
    }
    var proofLine: String {
        let merge = String(cycle.mergeHash.prefix(8))
        let integrity = cycle.loopReceiptIntegrity.nonEmpty ?? "integridade não publicada"
        return "integridade \(integrity) · merge \(merge) · ciclo \(cycle.cycleIndex)"
    }
}

struct SelfConstructionReceiptSheet: View {
    let receipt: SelfConstructionReceipt
    var canRevert: Bool = false
    var revertReceipt: AtlasAutonomosCycleRevertResponse? = nil
    var onRevert: (String, String) -> Void = { _, _ in }

    @Environment(\.dismiss) private var dismiss
    @State private var actor = ""
    @State private var reason = ""

    private var canSubmitRevert: Bool {
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

                if revertReceipt != nil {
                    Text("na fila · ainda não desfeito")
                        .font(AtlasFont.mono(11))
                        .foregroundStyle(AtlasTheme.domOperacional)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(RoundedRectangle(cornerRadius: 12).fill(AtlasTheme.domOperacional.opacity(0.08)))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AtlasTheme.domOperacional.opacity(0.35), lineWidth: 1))
                }

                // Humano fora do fluxo: silêncio/sucesso. Único verbo = veto.
                // Sem portão de aprovação em plumbing.
                if canRevert {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("veto retroativo · com recibo")
                            .font(AtlasFont.mono(10))
                            .tracking(0.9)
                            .foregroundStyle(AtlasTheme.textTertiary)
                        TextField("Quem autoriza", text: $actor)
                            .font(.system(.callout))
                            .textInputAutocapitalization(.never)
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 10).fill(AtlasTheme.surface.opacity(0.55)))
                        TextField("Motivo auditável", text: $reason, axis: .vertical)
                            .font(.system(.callout))
                            .lineLimit(2...4)
                            .padding(10)
                            .background(RoundedRectangle(cornerRadius: 10).fill(AtlasTheme.surface.opacity(0.55)))
                        Button {
                            onRevert(actor, reason)
                        } label: {
                            HStack(spacing: 7) {
                                Image(systemName: "arrow.uturn.backward")
                                Text("Desfazer — com recibo")
                            }
                            .font(.system(size: 14, weight: .medium))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .foregroundStyle(AtlasTheme.domOperacional)
                            .atlasCard(cornerRadius: 13)
                        }
                        .disabled(!canSubmitRevert)
                        .accessibilityIdentifier(A11yID.selfReceiptVeto)
                    }
                } else {
                    Text("silêncio · desfazer indisponível neste recorte")
                        .font(AtlasFont.mono(10))
                        .foregroundStyle(AtlasTheme.textTertiary)
                }

                Text("você não foi necessário — entrega sem portão")
                    .font(AtlasFont.serifItalic(13))
                    .foregroundStyle(AtlasTheme.textTertiary)

                Spacer(minLength: 0)
            }
            .padding(22)
        }
        .accessibilityIdentifier(A11yID.selfReceiptSheet)
    }
}
