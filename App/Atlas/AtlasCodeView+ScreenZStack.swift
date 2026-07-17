import SwiftUI
import AtlasCore

// Screen ZStack — peel de AtlasCodeView.

extension AtlasCodeView {
    var codeScreenZStack: some View {
        ZStack(alignment: .bottom) {
            AtlasTheme.bg.ignoresSafeArea()
            content
            askPill
        }
    }
}
