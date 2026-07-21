import SwiftUI
import AtlasCore

// Layout helpers — peel de RootHomeSections.

extension RootHomeSections {
    // Hairline com fade no fim — a linha premium do site, em miniatura.
    var rowDivider: some View {
        LinearGradient(
            colors: [AtlasTheme.separator, AtlasTheme.separator, AtlasTheme.separator.opacity(0)],
            startPoint: .leading, endPoint: .trailing
        )
        .frame(height: 1)
        .padding(.leading, AtlasTheme.Space.screen + 42)
    }

    func centered<V: View>(@ViewBuilder _ v: () -> V) -> some View {
        VStack { Spacer(); v(); Spacer() }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
