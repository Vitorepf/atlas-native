import SwiftUI
import AtlasCore

/// C13: estados do handoff LITERAIS; host alvo só depois de target_claimed.
struct AutonomosTransferStatus: View {
    let transfer: AtlasAutonomosTransferResponse
    let onRefresh: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Text(transfer.handoff.status)
                    .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.accent)
                Spacer()
                Button(action: onRefresh) {
                    Image(systemName: "arrow.clockwise").font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AtlasTheme.textSecondary)
                }
                .accessibilityLabel("atualizar status da transferência")
            }
            HStack(spacing: 6) {
                AutonomosChrome.tag(transfer.handoff.focus)
                if let host = transfer.handoff.source.host?.nonEmpty {
                    AutonomosChrome.tag("fonte \(host)")
                }
                if transfer.isTargetClaimed, let host = transfer.handoff.target.host?.nonEmpty {
                    AutonomosChrome.tag("alvo \(host)")
                }
            }
            if let note = transfer.note {
                Text(note).font(.caption).foregroundStyle(AtlasTheme.textSecondary).lineLimit(3)
            }
            if !transfer.isTargetClaimed {
                Text("Alvo ainda desconhecido — só aparece após target_claimed.")
                    .font(AtlasFont.serifItalic(12))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(AtlasTheme.goldVeil))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AtlasTheme.goldBorder, lineWidth: 1))
        .accessibilityElement(children: .contain)
        .accessibilityLabel("transferência \(transfer.handoff.status)")
    }
}

private extension String {
    var nonEmpty: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
