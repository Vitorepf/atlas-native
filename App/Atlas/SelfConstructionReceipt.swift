import AtlasCore
import Foundation
import SwiftUI

// Cycle 044 fuse → SelfConstructionReceipt.swift

struct SelfConstructionReceipt: Identifiable {
    let cycle: AtlasAutonomosCycle
    let finding: AtlasAutonomosFinding?

    var id: String { cycle.id }

    /// Merge só quando o servidor publica `merge_performed` e hash não vazio.
    var hasMergeProof: Bool {
        cycle.mergePerformed && cycle.mergeHash.nonEmpty != nil
    }
}

extension SelfConstructionReceipt {
    var title: String {
        if let findingTitle = finding?.title.nonEmpty { return findingTitle }
        if hasMergeProof { return "Entrega comprovada no ledger" }
        return "Ciclo registrado sem merge neste recorte"
    }

    var ruleLabel: String {
        if let ruleId = finding?.ruleId?.nonEmpty, let text = finding?.ruleText?.nonEmpty {
            return "\(ruleId) — \(text)"
        }
        if let ruleId = finding?.ruleId?.nonEmpty { return "\(ruleId) — regra publicada sem texto neste recorte." }
        return "Regra não publicada no recorte deste recibo."
    }
}

extension SelfConstructionReceipt {
    var proofLine: String {
        let integrity = cycle.loopReceiptIntegrity.nonEmpty ?? "integridade não publicada"
        var parts = ["integridade \(integrity)", "ciclo \(cycle.cycleIndex)"]
        if hasMergeProof, let hash = cycle.mergeHash.nonEmpty {
            parts.insert("merge \(String(hash.prefix(8)))", at: 1)
        } else {
            parts.append("merge não publicado")
        }
        return parts.joined(separator: " · ")
    }
}

extension SelfConstructionReceiptSheet {
    func spokenRuleLabel() -> String {
        "regra citada, \(receipt.ruleLabel)"
    }

    func spokenProofLabel() -> String {
        "prova, \(receipt.proofLine)"
    }
}

extension SelfConstructionReceiptSheet {
    func spokenSheetLabel() -> String {
        var parts = ["recibo de auto-construção", "ciclo \(receipt.cycle.cycleIndex)"]
        parts.append(receipt.hasMergeProof ? "merge comprovado no ledger" : "sem merge comprovado")
        return parts.joined(separator: ", ")
    }
}

extension SelfConstructionReceiptSheet {
    func spokenHumanSilenceLabel() -> String {
        "você não foi necessário, entrega sem portão"
    }

    func spokenRevertQueueLabel() -> String {
        "veto na fila, ainda não desfeito"
    }
}

extension SelfConstructionReceiptSheet {
    var receiptSealHeader: some View {
        HStack(spacing: 7) {
            Image(systemName: "checkmark.seal")
                .atlasSans(11, .bold)
                .accessibilityHidden(true)
            Text("RECIBO DE AUTO-CONSTRUÇÃO")
                .font(AtlasFont.mono(11))
                .tracking(1.0)
                .accessibilityHidden(true)
        }
        .foregroundStyle(AtlasTheme.textTertiary)
    }
}

extension SelfConstructionReceiptSheet {
    var canSubmitRevert: Bool {
        !actor.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

extension SelfConstructionReceiptSheet {
    func proofChrome<Content: View>(_ content: Content) -> some View {
        content
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AtlasTheme.surface.opacity(0.5), in: RoundedRectangle(cornerRadius: AtlasTheme.Radius.control))
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(spokenProofLabel())
    }
}

extension SelfConstructionReceiptSheet {
    @ViewBuilder
    var proofCopyBlock: some View {
        Text(receipt.proofLine)
            .font(AtlasFont.mono(12))
            .foregroundStyle(AtlasTheme.textPrimary)
            .textSelection(.enabled)
            .accessibilityHidden(true)
    }
}

extension SelfConstructionReceiptSheet {
    @ViewBuilder
    var revertQueueBanner: some View {
        if revertReceipt != nil {
            Text("na fila · ainda não desfeito")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.domOperacional)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control).fill(AtlasTheme.domOperacional.opacity(0.08)))
                .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control).stroke(AtlasTheme.domOperacional.opacity(0.35), lineWidth: 1))
                .transition(reduceMotion ? .identity : .opacity)
                .accessibilityLabel(spokenRevertQueueLabel())
        }
    }
}

extension SelfConstructionReceiptSheet {
    @ViewBuilder
    var ruleBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Regra citada")
                .font(AtlasFont.mono(10))
                .tracking(0.9)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            Text("“\(receipt.ruleLabel)”")
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenRuleLabel())
    }
}

extension SelfConstructionReceiptSheet {
    var receiptShell: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            receiptBody
        }
        .accessibilityIdentifier(A11yID.selfReceiptSheet)
        .accessibilityLabel(spokenSheetLabel())
    }
}

extension SelfConstructionReceiptSheet {
    @ViewBuilder
    var humanSilenceLine: some View {
        if receipt.hasMergeProof {
            Text("você não foi necessário — entrega sem portão")
                .font(AtlasFont.serifItalic(13))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityLabel(spokenHumanSilenceLabel())
        }
    }
}

extension SelfConstructionReceiptSheet {
    var receiptBody: some View {
        VStack(alignment: .leading, spacing: 14) {
            receiptSealHeader
            receiptTitleBlock
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
}

extension SelfConstructionReceiptSheet {
    var receiptTitleBlock: some View {
        Text(receipt.title)
            .font(AtlasFont.serif(18, .semibold))
            .foregroundStyle(AtlasTheme.textPrimary)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)
    }
}

extension SelfConstructionReceiptSheet {
    @ViewBuilder
    var vetoSection: some View {
        if canRevert {
            vetoFields
                .accessibilityElement(children: .contain)
                .accessibilityLabel("veto retroativo com recibo")
        }
    }
}

extension SelfConstructionReceiptSheet {
    func spokenActorHint() -> String {
        "nome de quem autoriza o veto retroativo"
    }

    func spokenReasonHint() -> String {
        "motivo auditável registrado no ledger"
    }
}

extension SelfConstructionReceiptSheet {
    func spokenVetoSubmitLabel(canSubmit: Bool) -> String {
        canSubmit ? "desfazer com recibo" : "desfazer indisponível, preencha autor e motivo"
    }

    func spokenVetoSubmitHint(canSubmit: Bool) -> String {
        canSubmit
            ? "envia veto retroativo auditável para este ciclo"
            : "informe quem autoriza e o motivo auditável"
    }
}

extension SelfConstructionReceiptSheet {
    var vetoSubmitButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onRevert(actor, reason)
        } label: {
            vetoSubmitLabel
        }
        .buttonStyle(PressableScale())
        .disabled(!canSubmitRevert)
        .accessibilityIdentifier(A11yID.selfReceiptVeto)
        .accessibilityLabel(spokenVetoSubmitLabel(canSubmit: canSubmitRevert))
        .accessibilityHint(spokenVetoSubmitHint(canSubmit: canSubmitRevert))
    }
}

extension SelfConstructionReceiptSheet {
    var vetoFields: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("veto retroativo · com recibo")
                .font(AtlasFont.mono(10))
                .tracking(0.9)
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
            vetoTextFields
            vetoSubmitButton
        }
    }
}

extension SelfConstructionReceiptSheet {
    var vetoSubmitLabel: some View {
        HStack(spacing: 7) {
            Image(systemName: "arrow.uturn.backward")
                .accessibilityHidden(true)
            Text("Desfazer — com recibo")
        }
        .atlasSans(14, .medium)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .foregroundStyle(AtlasTheme.domOperacional)
        .atlasCard(cornerRadius: 13)
    }
}

extension SelfConstructionReceiptSheet {
    @ViewBuilder
    var proofBlockStack: some View {
        VStack(alignment: .leading, spacing: 8) {
            proofBlockTitle
            proofCopyBlock
        }
    }
}

extension SelfConstructionReceiptSheet {
    var proofBlockTitle: some View {
        Text("Prova")
            .font(AtlasFont.mono(10))
            .tracking(0.9)
            .foregroundStyle(AtlasTheme.textTertiary)
            .accessibilityHidden(true)
    }
}

extension SelfConstructionReceiptSheet {
    @ViewBuilder
    var proofBlock: some View {
        proofChrome(proofBlockStack)
    }
}

extension SelfConstructionReceiptSheet {
    var vetoActorField: some View {
        TextField("Quem autoriza", text: $actor)
            .font(.system(.callout))
            .textInputAutocapitalization(.never)
            .padding(10)
            .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).fill(AtlasTheme.surface.opacity(0.55)))
            .accessibilityLabel("quem autoriza o veto")
            .accessibilityHint(spokenActorHint())
    }
}

extension SelfConstructionReceiptSheet {
    var vetoReasonField: some View {
        TextField("Motivo auditável", text: $reason, axis: .vertical)
            .font(.system(.callout))
            .lineLimit(2...4)
            .padding(10)
            .background(RoundedRectangle(cornerRadius: AtlasTheme.Radius.soft).fill(AtlasTheme.surface.opacity(0.55)))
            .accessibilityLabel("motivo auditável do veto")
            .accessibilityHint(spokenReasonHint())
    }
}

extension SelfConstructionReceiptSheet {
    var vetoTextFields: some View {
        Group {
            vetoActorField
            vetoReasonField
        }
    }
}

struct SelfConstructionReceiptSheet: View {
    let receipt: SelfConstructionReceipt
    var canRevert: Bool = false
    var revertReceipt: AtlasAutonomosCycleRevertResponse? = nil
    var onRevert: (String, String) -> Void = { _, _ in }

    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @State var actor = ""
    @State var reason = ""

    var body: some View {
        receiptShell
    }
}
