import SwiftUI
import AtlasCore

// Start-run receipt line — peel de AutonomosLoadedSection+ReceiptLines.

extension AutonomosRunReceiptLines {
    @ViewBuilder
    var startRunReceiptLine: some View {
        if let receipt = model.lastStartRunReceipt, receipt.isEnqueued {
            AutonomosInfoLine(
                "Novo ciclo NA FILA — ainda não iniciado. A execução só é real quando o lease aparecer no vivo.",
                spokenLabel: AutonomosLoadedSectionA11y.spokenStartRunEnqueued(receipt),
                identifier: A11yID.autonomosStartRunReceipt
            )
            .transition(receiptTransition)
        }
    }
}
