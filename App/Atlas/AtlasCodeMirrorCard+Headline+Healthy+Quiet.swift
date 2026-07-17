import AtlasCore
import SwiftUI

// Quiet mirror states — peel de AtlasCodeMirrorCard+Headline+Healthy.

extension AtlasCodeMirrorCard {
    @ViewBuilder
    var headlineHealthyNoMirror: some View {
        label("sem espelho configurado", color: AtlasTheme.textTertiary, icon: "circle.dashed")
    }

    @ViewBuilder
    var headlineHealthyUnknown: some View {
        label("espelho ainda não conhecido", color: AtlasTheme.textTertiary, icon: "questionmark.circle")
    }
}
