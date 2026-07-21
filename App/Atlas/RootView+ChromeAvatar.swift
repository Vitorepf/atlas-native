import SwiftUI
import AtlasCore

// Avatar do topBar — peel de RootView+Chrome. Abre o perfil do operador
// (era decorativo — affordance falsa; ordem do operador 2026-07-18).

extension RootView {
    var topBarAvatar: some View {
        Button {
            showingProfile = true
        } label: {
            Image(systemName: "person.fill")
                .atlasSans(18)
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 44, height: 44)
                .atlasGlassCircle()
        }
        .accessibilityIdentifier(A11yID.topbarProfile)
        .accessibilityLabel("perfil do operador")
        .accessibilityHint("abre seu perfil e o estado da sessão")
        .sheet(isPresented: $showingProfile) { AtlasProfileSheet() }
    }
}
