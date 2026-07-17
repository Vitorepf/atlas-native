import SwiftUI
import AtlasCore

/// Digest carregado mas sem agenda nem último resumo — peel de AutonomosDigestSection.
struct AutonomosDigestEmptyState: View {
    var body: some View {
        AutonomosCardEmptyState(
            caption: "resumo",
            copy: "Digest ainda não agendado pelo servidor — sem next_digest_at neste recorte.",
            accessibilityIdentifier: A11yID.autonomosDigestEmpty
        )
    }
}
