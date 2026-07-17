import SwiftUI
import AtlasCore

// Copy stack — peel de AutonomosChrome+Empty.

extension AutonomosCardEmptyState {
    var emptyCopyStack: some View {
        VStack(alignment: .leading, spacing: 6) {
            AutonomosChrome.sectionCaption(caption, role: .decorative)
            Text(copy)
                .font(AtlasFont.serifItalic(14))
                .foregroundStyle(AtlasTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
        }
    }
}
