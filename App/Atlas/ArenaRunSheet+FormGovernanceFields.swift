import SwiftUI
import AtlasCore

// Governance fields — peel de ArenaRunSheet+FormGovernance.

extension ArenaRunSheet {
    @ViewBuilder
    var governanceFields: some View {
        section("Governança") {
            // Campos na identidade da casa — .roundedBorder rendia caixas
            // BRANCAS no dark (a maior quebra da folha); rótulo diz o que é.
            fieldLabel("Operador")
            TextField("quem autoriza esta medição", text: $actor)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .modifier(ArenaFieldChrome())
                .accessibilityIdentifier(A11yID.arenaRunActor)
                .accessibilityHint(spokenActorHint())
            fieldLabel("Motivo")
            TextField("por que rodar agora (fica no recibo)", text: $reason, axis: .vertical)
                .lineLimit(2...4)
                .modifier(ArenaFieldChrome())
                .accessibilityIdentifier(A11yID.arenaRunReason)
                .accessibilityHint(spokenReasonHint())
        }
    }

    private func fieldLabel(_ text: String) -> some View {
        Text(text)
            .atlasSans(12, .medium)
            .foregroundStyle(AtlasTheme.textSecondary)
    }
}

struct ArenaFieldChrome: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(.callout))
            .foregroundStyle(AtlasTheme.textPrimary)
            .padding(.horizontal, 12).padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: AtlasTheme.Radius.control)
                    .fill(AtlasTheme.bgRecessed)
                    .overlay(RoundedRectangle(cornerRadius: AtlasTheme.Radius.control)
                        .stroke(AtlasTheme.separator, lineWidth: 1)))
    }
}
