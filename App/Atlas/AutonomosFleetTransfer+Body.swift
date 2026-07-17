import SwiftUI
import AtlasCore

// Corpo tags/notas — peel de AutonomosTransferStatus.
// Tags → AutonomosFleetTransfer+Tags.swift

extension AutonomosTransferStatus {
    var transferBody: some View {
        VStack(alignment: .leading, spacing: 8) {
            transferTags
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(transfer.transferSpokenSummary)
        .accessibilityAddTraits(transfer.isHandoffInFlight ? .updatesFrequently : [])
    }
}
