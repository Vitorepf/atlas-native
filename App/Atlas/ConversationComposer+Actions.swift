import SwiftUI
import PhotosUI
import AtlasCore

// Ações do composer — peel de ConversationComposer (régua anti-inchaço).

extension ConversationComposer {
    @ViewBuilder var composerSurface: some View {
        if expanded || liveBubble != nil {
            // Com execução viva o card cresce em cartão (capsule de 2 linhas
            // deformaria); a borda dourada continua reservada ao foco.
            RoundedRectangle(cornerRadius: 26, style: .continuous).fill(AtlasTheme.surface)
                .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(expanded ? AtlasTheme.goldBorder : AtlasTheme.separator, lineWidth: 1))
                .shadow(color: .black.opacity(0.18), radius: 12, y: 4)
        } else {
            Capsule(style: .continuous).fill(AtlasTheme.surface)
                .overlay(Capsule(style: .continuous).stroke(AtlasTheme.separator, lineWidth: 1))
        }
    }

    func dismissKeyboard() {
        if !reduceMotion { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
        if reduceMotion {
            focused.wrappedValue = false
        } else {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.86)) { focused.wrappedValue = false }
        }
    }

    func send() {
        if !reduceMotion { UIImpactFeedbackGenerator(style: .medium).impactOccurred() }
        let text = model.draftText
        let effort = model.effort
        Task { await model.send(text, effort: effort) }
    }

    func submitSteer(
        traceId: TraceID,
        instruction: String,
        scope: AtlasInteractionSteerScope
    ) {
        if !reduceMotion { UIImpactFeedbackGenerator(style: .soft).impactOccurred() }
        Task {
            await model.steerInteraction(traceId: traceId, instruction: instruction, scope: scope)
            if let receipt = steerReceipt(for: traceId) {
                model.toast = steerReceiptText(receipt)
            }
        }
    }

    func steerReceipt(for traceId: TraceID) -> AtlasInteractionSteerResponse? {
        guard let receipt = model.lastSteerReceipt else { return nil }
        if let receiptTrace = receipt.traceId, receiptTrace != traceId.rawValue { return nil }
        return receipt
    }

    func steerReceiptText(_ receipt: AtlasInteractionSteerResponse) -> String {
        receipt.isAccepted
            ? "na fila do próximo checkpoint"
            : "rejeitado · \(receipt.reason?.rawValue ?? "motivo_indisponivel")"
    }

    var queueChipLabel: String {
        let n = model.queuedMessages.count
        return n == 1 ? "Fila · 1" : "Fila · \(n)"
    }

    var queueAccessibilityLabel: String {
        let n = model.queuedMessages.count
        return n == 1
            ? "1 mensagem na fila durante a execução"
            : "\(n) mensagens na fila durante a execução"
    }
}
