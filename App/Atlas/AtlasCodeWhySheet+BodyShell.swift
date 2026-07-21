import SwiftUI
import AtlasCore

// Body shell — peel de AtlasCodeWhySheet.

extension AtlasCodeWhySheet {
    var whyBodyShell: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            whyScrollBody
        }
    }
}
