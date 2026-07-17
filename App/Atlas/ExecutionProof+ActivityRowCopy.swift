import SwiftUI
import AtlasCore

// Activity row copy — peel de ExecutionProof+ActivityRows.

extension ExecutionProof {
    func activityRowCopy(_ act: AtlasAgentActivity) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(act.title)
                .font(.system(.footnote)).foregroundStyle(AtlasTheme.textSecondary)
            if let d = act.detail, !d.isEmpty {
                Text(d).font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textTertiary)
                    .lineLimit(2).truncationMode(.middle)
            }
        }
    }
}
