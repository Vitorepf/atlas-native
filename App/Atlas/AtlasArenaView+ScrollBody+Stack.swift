import SwiftUI
import AtlasCore

// Scroll stack — peel de AtlasArenaView+ScrollBody.

extension AtlasArenaView {
    var arenaScrollStack: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            if let exception = model.regressionException {
                exceptionBanner(exception)
                    .transition(reduceMotion ? .opacity : .opacity.combined(with: .offset(y: -6)))
            }
            content
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .move(edge: .bottom)))
        }
        .padding(.horizontal, AtlasTheme.Space.screen)
        .padding(.vertical, 18)
    }
}
