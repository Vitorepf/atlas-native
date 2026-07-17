import SwiftUI
import AtlasCore

// Corpo tags/notas — peel de AutonomosTransferStatus.

extension AutonomosTransferStatus {
    var transferBody: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                AutonomosChrome.tag(transfer.handoff.focus)
                if let host = transfer.handoff.source.host?.nonEmpty {
                    AutonomosChrome.tag("fonte \(host)")
                }
                if transfer.isTargetClaimed, let host = transfer.handoff.target.host?.nonEmpty {
                    AutonomosChrome.tag("alvo \(host)")
                }
            }
            .accessibilityHidden(true)
            if !transfer.transferMilestoneTags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(transfer.transferMilestoneTags, id: \.self) { tag in
                        AutonomosChrome.tag(tag)
                    }
                }
                .accessibilityHidden(true)
            }
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
