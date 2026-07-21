import AtlasCore
import Foundation
import SwiftUI

// Cycle 043 fuse → AtlasCodeHealReceiptSheet.swift

// MARK: - Folha: Recibo de Cura (C25 — fato consumado, só veto)

struct AtlasCodeHealReceiptSheet: View {
    let heal: AtlasCodeHealResponse
    let onUndo: () -> Void
    @Environment(\.dismiss) var dismiss
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    var body: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            receiptContent()
        }
        .accessibilityIdentifier(A11yID.codeHealReceiptSheet)
        // Contain without fused sheet label so masthead/steps/undo stay focusable.
        .accessibilityElement(children: .contain)
    }
}

extension AtlasCodeHealReceiptSheet {
    func spokenMastheadLabel() -> String {
        hasCompletedHeal
            ? "curado sozinho, modo \(heal.mode)"
            : "cura, modo \(heal.mode)"
    }

    func spokenSilenceLabel() -> String {
        "você não foi necessário, cura concluída sem portão"
    }
}

extension AtlasCodeHealReceiptSheet {
    func spokenBlockedLabel(_ blocked: String) -> String {
        "cura bloqueada, \(blocked)"
    }

    func spokenEmptyStepsLabel() -> String {
        "recibo sem passos registrados pelo servidor"
    }
}

extension AtlasCodeHealReceiptSheet {
    func spokenStepLabel(_ receipt: AtlasCodeHealStepReceipt) -> String {
        let outcome = receipt.status == "completed" ? "concluído" : "falhou"
        var parts = ["passo \(receipt.step)", receipt.action, outcome]
        if !receipt.result.isEmpty { parts.append(receipt.result) }
        return parts.joined(separator: ", ")
    }

    func spokenUndoWindowLabel(_ note: String) -> String {
        "janela de veto, \(note)"
    }
}

extension AtlasCodeHealReceiptSheet {
    func spokenStepsSummaryLabel() -> String {
        "\(heal.stepReceipts.count) passo\(heal.stepReceipts.count == 1 ? "" : "s") no recibo"
    }
}

extension AtlasCodeHealReceiptSheet {
    var completedStepCount: Int {
        heal.stepReceipts.filter { $0.status == "completed" }.count
    }

    var hasCompletedHeal: Bool { completedStepCount > 0 }
}

extension AtlasCodeHealReceiptSheet {
    var undoExpiresAt: String? {
        heal.stepReceipts.compactMap(\.undoExpiresAt).first
    }

    var canUndo: Bool {
        heal.healId != nil && AtlasCodeUndoWindow.isOpen(expiresAt: undoExpiresAt)
    }
}

extension AtlasCodeHealReceiptSheet {
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
}

extension AtlasCodeHealReceiptSheet {
    func spokenUndoButtonLabel() -> String {
        canUndo ? "desfazer cura com recibo" : "desfazer indisponível"
    }

    func spokenUndoButtonHint() -> String {
        canUndo
            ? "envia veto retroativo auditável para esta cura"
            : "prazo de veto encerrado ou recibo sem identificador"
    }
}

extension AtlasCodeHealReceiptSheet {
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
}

extension AtlasCodeHealReceiptSheet {
    @ViewBuilder
    func receiptContent() -> some View {
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
}

extension AtlasCodeHealReceiptSheet {
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
}

extension AtlasCodeHealReceiptSheet {
  @ViewBuilder
  func stepCopy(_ receipt: AtlasCodeHealStepReceipt) -> some View {
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
}

extension AtlasCodeHealReceiptSheet {
  @ViewBuilder
  func stepRow(index: Int, receipt: AtlasCodeHealStepReceipt) -> some View {
    HStack(alignment: .top, spacing: 9) {
      Image(systemName: receipt.status == "completed" ? "checkmark" : "xmark")
        .atlasSans(10, .semibold)
        .foregroundStyle(receipt.status == "completed" ? AtlasCodePalette.healed : AtlasCodePalette.alert)
        .padding(.top, 2)
        .accessibilityHidden(true)
      stepCopy(receipt)
    }
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(spokenStepLabel(receipt))
    .accessibilityIdentifier(A11yID.codeHealStep(index))
  }
}

extension AtlasCodeHealReceiptSheet {
  @ViewBuilder
  func stepsBlock() -> some View {
    VStack(alignment: .leading, spacing: 8) {
      ForEach(Array(heal.stepReceipts.enumerated()), id: \.element.id) { index, receipt in
        stepRow(index: index, receipt: receipt)
      }
    }
    .padding(12)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(AtlasTheme.surface.opacity(0.5), in: RoundedRectangle(cornerRadius: AtlasTheme.Radius.control))
    // Contain without fused label: each step row stays focusable.
    .accessibilityElement(children: .contain)
  }
}

extension AtlasCodeHealReceiptSheet {
    @ViewBuilder
    var receiptStepsOrEmpty: some View {
        if heal.stepReceipts.isEmpty {
            Text("sem passos registrados no recibo")
                .font(AtlasFont.mono(11))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityLabel(spokenEmptyStepsLabel())
        } else {
            stepsBlock()
        }
    }
}

extension AtlasCodeHealReceiptSheet {
    var undoButton: some View {
        Button {
            // Medium: undo with receipt is governed commit.
            AtlasMotion.mediumImpact(reduceMotion: reduceMotion)
            onUndo()
            dismiss()
        } label: {
            undoButtonLabel
        }
        .buttonStyle(PressableScale())
        .transition(reduceMotion ? .identity : .opacity)
        .accessibilityIdentifier(A11yID.codeHealUndo)
        .accessibilityLabel(spokenUndoButtonLabel())
        .accessibilityHint(spokenUndoButtonHint())
        .accessibilityAddTraits(.isButton)
        .accessibilitySortPriority(9)
    }
}

extension AtlasCodeHealReceiptSheet {
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
            undoButton
        }
    }
}

extension AtlasCodeHealReceiptSheet {
    var undoButtonLabel: some View {
        HStack(spacing: 7) {
            Image(systemName: "arrow.uturn.backward")
                .accessibilityHidden(true)
            Text("Desfazer — com recibo")
        }
        .atlasSans(14, .medium)
        .frame(maxWidth: .infinity, minHeight: 48)
        .padding(.vertical, 12)
        .foregroundStyle(AtlasTheme.textSecondary)
        .contentShape(Rectangle())
        .atlasCard(cornerRadius: 13)
    }
}
