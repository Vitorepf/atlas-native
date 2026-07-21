import SwiftUI
import AtlasCore

// MARK: - Folha: Recibo de Cura (C25 — fato consumado, só veto)
// WAVE-009: fused instrument — silence when healthy, vocab “curado sozinho”.

struct AtlasCodeHealReceiptSheet: View {
    let heal: AtlasCodeHealResponse
    let onUndo: () -> Void
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 12) {
                masthead
                healStatusLines
                receiptStepsOrEmpty
                receiptUndoFooter
                Spacer(minLength: 0)
            }
            .padding(22)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: canUndo)
        }
        .accessibilityIdentifier(A11yID.codeHealReceiptSheet)
        .accessibilityLabel(spokenSheetLabel())
    }

    // MARK: - Gates

    var completedStepCount: Int {
        heal.stepReceipts.filter { $0.status == "completed" }.count
    }
    var hasCompletedHeal: Bool { completedStepCount > 0 }

    var undoExpiresAt: String? {
        heal.stepReceipts.compactMap(\.undoExpiresAt).first
    }

    var canUndo: Bool {
        heal.healId != nil && AtlasCodeUndoWindow.isOpen(expiresAt: undoExpiresAt)
    }

    // MARK: - Chrome

    var masthead: some View {
        HStack(spacing: 7) {
            Image(systemName: hasCompletedHeal ? "checkmark" : "exclamationmark.triangle")
                .atlasSans(10, .bold)
                .accessibilityHidden(true)
            Text(hasCompletedHeal
                 ? "CURADO SOZINHO · \(heal.mode.uppercased())"
                 : "CURA · \(heal.mode.uppercased())")
                .atlasSans(9, .bold)
                .tracking(1.2)
                .accessibilityHidden(true)
        }
        .foregroundStyle(hasCompletedHeal ? AtlasCodePalette.healed : AtlasTheme.textTertiary)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenMastheadLabel())
    }

    @ViewBuilder
    var healStatusLines: some View {
        if hasCompletedHeal {
            Text("você não foi necessário")
                .font(AtlasFont.serif(20, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel(spokenSilenceLabel())
        }
        if let blocked = heal.blocked, !blocked.isEmpty {
            Text("bloqueado · \(blocked)")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasCodePalette.alert)
                .accessibilityLabel(spokenBlockedLabel(blocked))
        }
    }

    @ViewBuilder
    var receiptStepsOrEmpty: some View {
        if heal.stepReceipts.isEmpty {
            Text("sem passos registrados no recibo")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityLabel(spokenEmptyStepsLabel())
        } else {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(Array(heal.stepReceipts.enumerated()), id: \.element.id) { index, receipt in
                    stepRow(index: index, receipt: receipt)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AtlasTheme.surface.opacity(0.5), in: RoundedRectangle(cornerRadius: AtlasTheme.Radius.control))
            .accessibilityElement(children: .contain)
            .accessibilityLabel(spokenStepsSummaryLabel())
        }
    }

    @ViewBuilder
    func stepRow(index: Int, receipt: AtlasCodeHealStepReceipt) -> some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: receipt.status == "completed" ? "checkmark" : "xmark")
                .atlasSans(10, .semibold)
                .foregroundStyle(receipt.status == "completed" ? AtlasCodePalette.healed : AtlasCodePalette.alert)
                .padding(.top, 2)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(receipt.action)
                    .atlasSans(13)
                    .foregroundStyle(AtlasTheme.textPrimary)
                    .accessibilityHidden(true)
                if !receipt.result.isEmpty {
                    Text(receipt.result)
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .accessibilityHidden(true)
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(spokenStepLabel(receipt))
        .accessibilityIdentifier(A11yID.codeHealStep(index))
    }

    @ViewBuilder
    var receiptUndoFooter: some View {
        if let note = AtlasCodeUndoWindow.note(expiresAt: undoExpiresAt) {
            Text(note)
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityIdentifier(A11yID.codeHealUndoWindow)
                .accessibilityLabel(spokenUndoWindowLabel(note))
        }
        if canUndo {
            Button {
                AtlasMotion.softImpact(reduceMotion: reduceMotion)
                onUndo()
                dismiss()
            } label: {
                HStack(spacing: 7) {
                    Image(systemName: "arrow.uturn.backward")
                        .accessibilityHidden(true)
                    Text("Desfazer — com recibo")
                }
                .atlasSans(14, .medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundStyle(AtlasTheme.textSecondary)
                .atlasCard(cornerRadius: 13)
            }
            .buttonStyle(PressableScale())
            .transition(reduceMotion ? .identity : .opacity)
            .accessibilityIdentifier(A11yID.codeHealUndo)
            .accessibilityLabel(spokenUndoButtonLabel())
            .accessibilityHint(spokenUndoButtonHint())
        }
    }

    // MARK: - Spoken

    func spokenSheetLabel() -> String {
        var parts = ["recibo de cura", heal.mode]
        if heal.stepReceipts.isEmpty {
            parts.append("sem passos no recibo")
        } else {
            parts.append("\(heal.stepReceipts.count) passo\(heal.stepReceipts.count == 1 ? "" : "s")")
            parts.append("\(completedStepCount) concluído\(completedStepCount == 1 ? "" : "s")")
        }
        if let blocked = heal.blocked, !blocked.isEmpty {
            parts.append("bloqueado, \(blocked)")
        }
        return parts.joined(separator: ", ")
    }

    func spokenMastheadLabel() -> String {
        hasCompletedHeal
            ? "curado sozinho, modo \(heal.mode)"
            : "cura, modo \(heal.mode)"
    }

    func spokenSilenceLabel() -> String {
        "você não foi necessário, cura concluída sem portão"
    }

    func spokenBlockedLabel(_ blocked: String) -> String {
        "cura bloqueada, \(blocked)"
    }

    func spokenEmptyStepsLabel() -> String {
        "recibo sem passos registrados pelo servidor"
    }

    func spokenStepLabel(_ receipt: AtlasCodeHealStepReceipt) -> String {
        let outcome = receipt.status == "completed" ? "concluído" : "falhou"
        var parts = ["passo \(receipt.step)", receipt.action, outcome]
        if !receipt.result.isEmpty { parts.append(receipt.result) }
        return parts.joined(separator: ", ")
    }

    func spokenUndoWindowLabel(_ note: String) -> String {
        "janela de veto, \(note)"
    }

    func spokenStepsSummaryLabel() -> String {
        "\(heal.stepReceipts.count) passo\(heal.stepReceipts.count == 1 ? "" : "s") no recibo"
    }

    func spokenUndoButtonLabel() -> String {
        canUndo ? "desfazer cura com recibo" : "desfazer indisponível"
    }

    func spokenUndoButtonHint() -> String {
        canUndo
            ? "envia veto retroativo auditável para esta cura"
            : "prazo de veto encerrado ou recibo sem identificador"
    }
}
