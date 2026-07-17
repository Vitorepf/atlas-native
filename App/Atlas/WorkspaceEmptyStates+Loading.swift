import SwiftUI
import AtlasCore

// Loading shell — peel de WorkspaceEmptyStates.

struct WorkspaceLoadingEmpty: View {
    var reduceMotion: Bool

    var body: some View {
        VStack(spacing: 18) {
            BreathingGlyph(reduceMotion: reduceMotion)
            Text("abrindo conversas…")
                .font(AtlasFont.serifItalic(15)).foregroundStyle(AtlasTheme.textTertiary)
        }
        .frame(maxWidth: .infinity).padding(.top, 72)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("abrindo conversas")
    }
}
