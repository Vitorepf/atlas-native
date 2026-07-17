import AtlasCore
import SwiftUI

// Healthy mirror states — peel de AtlasCodeMirrorCard+Headline.

extension AtlasCodeMirrorCard {
    @ViewBuilder
    var headlineHealthy: some View {
        switch response.state {
        case .mirrored:
            label("tudo espelhado · a verdade fica no Mac", color: AtlasTheme.textSecondary, icon: "checkmark")
        case .pending(let commits):
            label(
                commits == 1 ? "1 commit ainda só no Mac" : "\(commits) commits ainda só no Mac",
                color: AtlasTheme.textSecondary,
                icon: "internaldrive"
            )
        case .noMirror:
            label("sem espelho configurado", color: AtlasTheme.textTertiary, icon: "circle.dashed")
        case .unknown:
            label("espelho ainda não conhecido", color: AtlasTheme.textTertiary, icon: "questionmark.circle")
        default:
            EmptyView()
        }
    }
}
