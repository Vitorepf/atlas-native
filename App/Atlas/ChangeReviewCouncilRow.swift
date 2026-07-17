import SwiftUI
import AtlasCore

/// Linha de membro do conselho — peel de ChangeReviewCouncilSection.

struct ChangeReviewCouncilMemberRow: View {
    let member: AtlasTraceGovernance.CouncilMember

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 7) {
                Image(systemName: member.succeeded ? "checkmark" : "xmark")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(member.succeeded ? Color(hex: 0x83B46D) : Color(hex: 0xE08C8C))
                Text(member.provider)
                    .font(AtlasFont.mono(10))
                    .foregroundStyle(AtlasTheme.textSecondary)
                if let model = member.model {
                    Text(model)
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .lineLimit(1)
                }
                Spacer()
                Text(member.status)
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(member.succeeded ? Color(hex: 0x83B46D) : Color(hex: 0xE08C8C))
            }
            HStack(spacing: 8) {
                if let hash = member.responseHash {
                    Text("hash \(String(hash.prefix(12)))")
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .accessibilityLabel("hash de resposta, \(String(hash.prefix(12)))")
                }
                if let code = member.errorCode {
                    Text(code)
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(Color(hex: 0xE08C8C))
                }
                if let latency = member.latencyMs {
                    Text("\(latency)ms")
                        .font(AtlasFont.mono(9))
                        .foregroundStyle(AtlasTheme.textTertiary)
                        .monospacedDigit()
                }
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(councilSpoken)
    }

    private var councilSpoken: String {
        var parts = [member.provider]
        if let model = member.model { parts.append(model) }
        parts.append(member.succeeded ? "concluído" : "falhou")
        if let hash = member.responseHash {
            parts.append("hash de resposta \(String(hash.prefix(12)))")
        }
        if let code = member.errorCode { parts.append("erro \(code)") }
        if let latency = member.latencyMs { parts.append("\(latency) milissegundos") }
        return parts.joined(separator: ", ")
    }
}
