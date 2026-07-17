import SwiftUI

// Caption + titles — peel de QueuedFollowUpsSheet+Content.

extension QueuedFollowUpsSheet {
    @ViewBuilder
    func queueOrderCaption(total: Int) -> some View {
        if total > 1 {
            Text("ordem da fila · a cabeça envia quando o turno terminar")
                .font(.system(size: 12))
                .foregroundStyle(AtlasTheme.textTertiary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
                .accessibilityAddTraits(.isHeader)
                .accessibilityLabel(
                    "fila ordenada; a primeira mensagem envia quando o turno atual terminar"
                )
        }
    }

    func sheetTitle(count: Int) -> String {
        count == 1 ? "Fila · 1" : "Fila · \(count)"
    }

    func spokenQueueSheetLabel() -> String {
        let n = model.queuedMessages.count
        if n == 0 { return "fila vazia" }
        return n == 1 ? "fila, 1 mensagem" : "fila, \(n) mensagens"
    }
}
