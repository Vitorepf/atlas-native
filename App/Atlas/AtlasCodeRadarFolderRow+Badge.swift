import SwiftUI
import AtlasCore

// Exception badge — peel de AtlasCodeFolderRow header.

extension AtlasCodeFolderRow {
    @ViewBuilder
    var exceptionBadge: some View {
        if verifiedExceptionCount > 0 {
            HStack(spacing: 4) {
                Image(systemName: "exclamationmark.triangle")
                    .atlasSans(9, .semibold)
                Text("\(verifiedExceptionCount)")
                    .atlasSans(11, .semibold)
                    .monospacedDigit()
            }
            .foregroundStyle(AtlasCodePalette.alert)
            .accessibilityHidden(true)
        }
    }
}
