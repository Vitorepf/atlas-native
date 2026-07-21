import SwiftUI
import UIKit
import AtlasCore

// Sheet toolbar — peel de ArtifactSheet+Chrome.

extension ArtifactSheet {
    func artifactSheetToolbar<Content: View>(_ content: Content) -> some View {
        content
            .navigationTitle("Artefatos")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    AtlasCloseToolbarButton(
                        spokenLabel: "fechar artefatos",
                        spokenHint: "volta para a conversa",
                        reduceMotion: reduceMotion
                    ) { dismiss() }
                }
            }
            .overlay(alignment: .top) { toast }
    }
}
