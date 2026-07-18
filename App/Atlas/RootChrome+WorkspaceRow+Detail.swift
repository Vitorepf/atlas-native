import SwiftUI
import AtlasCore

// Detail text do WorkspaceRow — peel de RootChrome+WorkspaceRow+Content.

extension WorkspaceRow {
    @ViewBuilder
    var rowDetail: some View {
        // Voz calma: o ponto vermelho (badge) é o único alerta da linha —
        // texto em vermelho por cima dele era sinal duplicado gritando.
        if let detail, !detail.isEmpty {
            Text(detail)
                .font(.system(.caption))
                .foregroundStyle(AtlasTheme.textSecondary)
                .lineLimit(1)
                .accessibilityHidden(true)
        }
    }
}
