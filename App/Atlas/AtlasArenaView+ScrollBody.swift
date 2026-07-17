import SwiftUI
import AtlasCore

// Arena scroll body — peel de AtlasArenaView.

extension AtlasArenaView {
    var arenaScrollBody: some View {
        ScrollView {
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
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: contentPhaseID)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: model.regressionException != nil)
        }
        .scrollIndicators(.hidden)
    }
}
