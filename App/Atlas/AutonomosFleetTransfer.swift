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
            if !milestoneTags.isEmpty {
                HStack(spacing: 6) {
                    ForEach(milestoneTags, id: \.self) { tag in
                        AutonomosChrome.tag(tag)
                    }
                }
            }
            if let note = transfer.note?.nonEmpty {
                Text(note).font(.caption).foregroundStyle(AtlasTheme.textSecondary).lineLimit(3)
            }
            if transfer.isHandoffInFlight {
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
        .accessibilityLabel(spokenSummary)
        .accessibilityIdentifier(A11yID.autonomosTransferStatus)
    }

    private var milestoneTags: [String] {
        var tags: [String] = []
        if let requested = transfer.handoff.requestedAt?.nonEmpty {
            tags.append("pedido \(requested)")
        }
        if let released = transfer.handoff.sourceReleasedAt?.nonEmpty {
            tags.append("fonte liberada \(released)")
        }
        if let enqueued = transfer.handoff.successorEnqueuedAt?.nonEmpty {
            tags.append("sucessor enfileirado \(enqueued)")
        }
        return tags
    }

    private var spokenSummary: String {
        var parts = ["transferência", transfer.handoff.status]
        if let host = transfer.handoff.source.host?.nonEmpty {
            parts.append("fonte \(host)")
        }
        if transfer.isTargetClaimed, let host = transfer.handoff.target.host?.nonEmpty {
            parts.append("alvo \(host)")
        } else if transfer.isHandoffInFlight {
            parts.append("alvo ainda desconhecido")
        }
        return parts.joined(separator: ", ")
    }
}
