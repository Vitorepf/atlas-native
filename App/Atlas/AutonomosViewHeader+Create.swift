import SwiftUI

// Botão + (Novo Autônomo) — peel de AutonomosViewHeader.

extension AutonomosViewHeader {
    var createButton: some View {
        Button {
            AtlasMotion.softImpact(reduceMotion: reduceMotion)
            onCreate()
        } label: {
            Image(systemName: "plus")
                .atlasSans(17, .semibold)
                .foregroundStyle(AtlasTheme.textPrimary)
                .frame(width: 40, height: 40)
                .atlasGlassCircle()
        }
        .accessibilityLabel("Novo Autônomo")
        .accessibilityHint("Cria um Autônomo com nome e carta")
        .accessibilityIdentifier(A11yID.autonomosNew)
    }
}
