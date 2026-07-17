import SwiftUI
import AtlasCore

// Recibo visual — peel de SteerInteractionSheet; só dados do contrato steer.

extension SteerInteractionSheet {
    func receiptLine(_ receipt: AtlasInteractionSteerResponse) -> some View {
        let text = receipt.isAccepted
            ? "na fila do próximo checkpoint"
            : "rejeitado · \(receipt.reason?.rawValue ?? "motivo_indisponivel")"

        return Text(text)
            .font(AtlasFont.mono(11))
            .foregroundStyle(receipt.isAccepted ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 12).fill(AtlasTheme.surface.opacity(0.65)))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AtlasTheme.separatorSoft, lineWidth: 1))
    }
}
