import SwiftUI
import AtlasCore

// Connector rail — peel de AtlasCodeWhySheet+RowMeta.

extension AtlasCodeWhySheet {
    @ViewBuilder
    func whyRowConnector(isLast: Bool) -> some View {
        if !isLast {
            Rectangle()
                .fill(AtlasTheme.accent.opacity(0.35))
                .frame(width: 1)
                .frame(minHeight: 56)
                .accessibilityHidden(true)
        }
    }
}
