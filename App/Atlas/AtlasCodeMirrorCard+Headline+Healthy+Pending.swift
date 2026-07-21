import AtlasCore
import SwiftUI

// Pending state — peel de AtlasCodeMirrorCard+Headline+Healthy.

extension AtlasCodeMirrorCard {
    @ViewBuilder
    func headlineHealthyPending(commits: Int) -> some View {
        label(
            commits == 1 ? "1 commit ainda só no Mac" : "\(commits) commits ainda só no Mac",
            color: AtlasTheme.textSecondary,
            icon: "internaldrive"
        )
    }
}
