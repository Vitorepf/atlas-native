import SwiftUI
import AtlasCore

// Detail scroll body — peel de AutonomosDetailSheet.

extension AutonomosPublicDetailSheet {
    var detailScrollBody: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let backlog {
                    AutonomosDetailContent.rows(kind: kind, backlog: backlog)
                        .transition(reduceMotion ? .identity : .opacity)
                } else {
                    emptyProjection
                }
            }
            .padding(AtlasTheme.Space.screen)
            .animation(reduceMotion ? nil : AtlasMotion.editorial, value: contentPhaseID)
        }
        .background(AtlasTheme.bg.ignoresSafeArea())
        .navigationTitle(kind.title)
        .toolbar { detailToolbar }
    }
}
