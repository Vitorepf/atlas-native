import SwiftUI
import AtlasCore

// Run receipts — peel de AutonomosLoadedSection.

extension AutonomosLoadedSection {
    var receiptPhaseID: String {
        var parts: [String] = []
        if let receipt = model.lastStartRunReceipt, receipt.isEnqueued {
            parts.append("start:\(receipt.status):\(receipt.launch)")
        }
        if let transfer = model.lastTransferReceipt, transfer.shouldDisplayTransferStatus {
            parts.append("transfer:\(transfer.handoff.handoffId):\(transfer.handoff.status)")
        }
        if let receipt = model.lastControlReceipt {
            parts.append("control:\(receipt.action.rawValue):\(receipt.applied)")
        }
        if let error = model.controlError { parts.append("error:\(error)") }
        return parts.joined(separator: "|")
    }

    @ViewBuilder
    var runReceiptLines: some View {
        AutonomosRunReceiptLines(model: model, reduceMotion: reduceMotion)
    }
}

private struct AutonomosRunReceiptLines: View {
    let model: AutonomosModel
    let reduceMotion: Bool

    var body: some View {
        Group {
            if let receipt = model.lastStartRunReceipt, receipt.isEnqueued {
                AutonomosInfoLine(
                    "Novo ciclo NA FILA — ainda não iniciado. A execução só é real quando o lease aparecer no vivo.",
                    spokenLabel: AutonomosLoadedSectionA11y.spokenStartRunEnqueued(receipt),
                    identifier: A11yID.autonomosStartRunReceipt
                )
                .transition(receiptTransition)
            }
            if let transfer = model.lastTransferReceipt, transfer.shouldDisplayTransferStatus {
                AutonomosTransferStatus(transfer: transfer) {
                    Task { await model.refreshTransferStatus() }
                }
                .transition(receiptTransition)
            }
            if let receipt = model.lastControlReceipt {
                AutonomosControlReceiptLine(receipt: receipt)
                    .transition(receiptTransition)
            }
        }
        .animation(reduceMotion ? nil : AtlasMotion.editorial, value: receiptPhaseID)
    }

    private var receiptPhaseID: String {
        var parts: [String] = []
        if let receipt = model.lastStartRunReceipt, receipt.isEnqueued {
            parts.append("start:\(receipt.status):\(receipt.launch)")
        }
        if let transfer = model.lastTransferReceipt, transfer.shouldDisplayTransferStatus {
            parts.append("transfer:\(transfer.handoff.handoffId):\(transfer.handoff.status)")
        }
        if let receipt = model.lastControlReceipt {
            parts.append("control:\(receipt.action.rawValue):\(receipt.applied)")
        }
        return parts.joined(separator: "|")
    }

    private var receiptTransition: AnyTransition {
        reduceMotion ? .identity : .opacity.combined(with: .offset(y: 6))
    }
}
