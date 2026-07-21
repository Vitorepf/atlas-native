import SwiftUI

// Header layout — peel de AutonomosViewHeader.

extension AutonomosViewHeader {
    var headerLayout: some View {
        HStack(spacing: 12) {
            backButton
            titleBlock
            Spacer()
            trailingButton
        }
        .padding(.horizontal, AtlasTheme.Space.screen).padding(.vertical, 8)
    }

    @ViewBuilder
    private var trailingButton: some View {
        switch trailing {
        case .none:
            EmptyView()
        case .create:
            createButton
        case .refresh:
            refreshButton
        }
    }
}
