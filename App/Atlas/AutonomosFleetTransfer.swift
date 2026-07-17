import SwiftUI
import AtlasCore

/// C13: estados do handoff LITERAIS; host alvo só depois de target_claimed.
struct AutonomosTransferStatus: View {
    let transfer: AtlasAutonomosTransferResponse
    let onRefresh: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Text(transfer.handoff.status)
                    .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.accent)
                    .accessibilityHidden(true)
                Spacer()
                Button {
                    AtlasMotion.softImpact(reduceMotion: reduceMotion)
                    onRefresh()
                } label: {
                    Image(systemName: "arrow.clockwise").font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AtlasTheme.textSecondary)
                }
                .accessibilityLabel("atualizar status da transferência")
                .accessibilityHint("busca o recibo mais recente do servidor")
                .accessibilityIdentifier(A11yID.autonomosTransferRefresh)
            }
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
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 12).fill(AtlasTheme.goldVeil))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AtlasTheme.goldBorder, lineWidth: 1))
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier(A11yID.autonomosTransferStatus)
    }
}
