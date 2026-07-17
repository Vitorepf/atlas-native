import AtlasCore
import SwiftUI

// Content shell — peel de AtlasCodeRadarView.

extension AtlasCodeRadarView {
    var radarContentShell: some View {
        ZStack {
            AtlasTheme.bg.ignoresSafeArea()
            radarNavShell(
                radarContent
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .bottom)))
                    .animation(reduceMotion ? nil : AtlasMotion.editorial, value: contentPhaseID)
            )
        }
    }
}
