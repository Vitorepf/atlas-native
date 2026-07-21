import SwiftUI
import AtlasCore

// Leading visual do arquivo — peel de ChangeReviewFileRow+Meta.

extension ChangeReviewFileRow {
    var fileLeadingRow: some View {
        HStack(spacing: 8) {
            Text(displayName)
                .font(AtlasFont.mono(11)).foregroundStyle(AtlasTheme.textPrimary).lineLimit(1)
                .accessibilityHidden(true)
            if let kind = fileKindCaption {
                Text(kind).font(AtlasFont.mono(9))
                    .foregroundStyle(kind == "novo" ? AtlasTheme.domAutonomos : AtlasTheme.domOperacional)
                    .accessibilityHidden(true)
            }
            Spacer()
            fileTrailing
        }
    }
}
