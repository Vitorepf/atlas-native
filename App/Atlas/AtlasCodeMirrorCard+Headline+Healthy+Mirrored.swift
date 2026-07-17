import AtlasCore
import SwiftUI

// Mirrored state — peel de AtlasCodeMirrorCard+Headline+Healthy.

extension AtlasCodeMirrorCard {
    @ViewBuilder
    var headlineHealthyMirrored: some View {
        label("tudo espelhado · a verdade fica no Mac", color: AtlasTheme.textSecondary, icon: "checkmark")
    }
}
