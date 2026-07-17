import AtlasCore
import SwiftUI

// Blocked mirror state — peel de AtlasCodeMirrorCard+Headline.

extension AtlasCodeMirrorCard {
    @ViewBuilder
    var headlineBlocked: some View {
        if case .blocked = response.state {
            label(
                "segredo detectado · nada sai da máquina",
                color: AtlasCodePalette.alert,
                icon: "exclamationmark.triangle"
            )
        }
    }
}
