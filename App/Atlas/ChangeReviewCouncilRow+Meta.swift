import SwiftUI
import AtlasCore

/// Meta secundária do membro do conselho — peel de ChangeReviewCouncilRow.
/// Latency → ChangeReviewCouncilRow+MetaLatency.swift

extension ChangeReviewCouncilMemberRow {
    @ViewBuilder
    var metaRow: some View {
        HStack(spacing: 8) {
            if let hash = member.responseHash {
                Text("hash \(String(hash.prefix(12)))")
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .accessibilityHidden(true)
            }
            if let code = member.errorCode {
                Text(code)
                    .font(AtlasFont.mono(9))
                    .foregroundStyle(Color(hex: 0xE08C8C))
                    .accessibilityHidden(true)
            }
            metaLatency
        }
    }
}
