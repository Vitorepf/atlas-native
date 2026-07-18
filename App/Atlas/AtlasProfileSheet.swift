import SwiftUI
import AtlasCore

// Perfil do operador — sheet da home (ordem do operador 2026-07-18:
// "no botão de perfil cria uma tela, ultra premium e padronizada").
// Sheet = profundidade da home, não rota nova (canon §6 intacto).
// Rows → AtlasProfileSheet+Rows.swift

struct AtlasProfileSheet: View {
    @Environment(AtlasSession.self) var session
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    profileMasthead
                    profileRows
                }
                .padding(.horizontal, AtlasTheme.Space.screen)
                .padding(.top, 18)
            }
            .background(AtlasTheme.bg.ignoresSafeArea())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fechar") { dismiss() }
                        .atlasSans(15, .medium)
                }
            }
            .accessibilityIdentifier(A11yID.profileSheet)
        }
    }

    private var profileMasthead: some View {
        VStack(spacing: 10) {
            Image(systemName: "person.fill")
                .atlasSans(26)
                .foregroundStyle(AtlasTheme.textSecondary)
                .frame(width: 72, height: 72)
                .atlasGlassCircle()
                .accessibilityHidden(true)
            Text("Vitor")
                .font(AtlasFont.serif(24, .semibold))
                .foregroundStyle(AtlasTheme.textPrimary)
            Text("operador do Atlas")
                .atlasSans(13)
                .foregroundStyle(AtlasTheme.textTertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Vitor, operador do Atlas")
    }
}
