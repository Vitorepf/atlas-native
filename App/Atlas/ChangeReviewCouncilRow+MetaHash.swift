import SwiftUI
import AtlasCore

// Hash/code chips — peel de ChangeReviewCouncilRow+Meta.

extension ChangeReviewCouncilMemberRow {
    @ViewBuilder
    var metaHashCode: some View {
        if let hash = member.responseHash {
            Text("hash \(String(hash.prefix(12)))")
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.textTertiary)
                .accessibilityHidden(true)
        }
        if let code = member.errorCode {
            Text(code)
                .font(AtlasFont.mono(9))
                .foregroundStyle(AtlasTheme.alert)
                .accessibilityHidden(true)
        }
    }
}
