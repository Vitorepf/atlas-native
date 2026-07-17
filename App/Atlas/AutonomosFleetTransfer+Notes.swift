import SwiftUI
import AtlasCore

// Notes do transfer body — peel de AutonomosFleetTransfer+Body.

extension AutonomosTransferStatus {
    @ViewBuilder
    var transferNotes: some View {
        if let note = transfer.note?.nonEmpty {
            Text(note).font(.caption).foregroundStyle(AtlasTheme.textSecondary).lineLimit(3)
                .accessibilityHidden(true)
        }
        if transfer.isHandoffInFlight {
            Text("Alvo ainda desconhecido — só aparece após target_claimed.")
                .font(AtlasFont.serifItalic(12))
                .foregroundStyle(AtlasTheme.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
        }
    }
}
