import SwiftUI
import AtlasCore

// Empty state — peel de AutonomosPublicDetailSheet.

extension AutonomosPublicDetailSheet {
    var emptyProjection: some View {
        Text("Sem projeção pública disponível agora.")
            .font(.footnote)
            .foregroundStyle(AtlasTheme.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .atlasCard(cornerRadius: AtlasTheme.Radius.control)
            .accessibilityLabel(spokenEmptyLabel())
            .accessibilityIdentifier(A11yID.autonomosDetailEmpty)
    }
}
