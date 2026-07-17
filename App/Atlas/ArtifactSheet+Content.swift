import SwiftUI
import AtlasCore

// Shell de conteúdo — peel de ArtifactSheet.
// Empty → ArtifactSheet+Empty.swift

extension ArtifactSheet {
    @ViewBuilder
    var content: some View {
        if showsEmptyOrUnavailable {
            emptyOrUnavailable
        } else if hasDeliveryProof, !mountComplete {
            artifactMount
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 14)
        } else {
            VStack(alignment: .leading, spacing: 12) {
                Text("ARTEFATOS DO TURNO · \(artifacts?.workspaceLabel ?? "workspace")")
                    .font(AtlasFont.mono(10)).tracking(1.0)
                    .foregroundStyle(AtlasTheme.textTertiary)
                    .padding(.horizontal, AtlasTheme.Space.screen)
                    .padding(.top, 14)
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        artifactList
                        previewPane
                    }
                    .padding(.horizontal, AtlasTheme.Space.screen)
                    .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}
