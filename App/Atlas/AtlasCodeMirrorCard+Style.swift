import AtlasCore
import SwiftUI

// Style + a11y helpers — peel de AtlasCodeMirrorCard.

extension AtlasCodeMirrorCard {
    var background: Color {
        if case .blocked = response.state { return AtlasCodePalette.alert.opacity(0.05) }
        return AtlasTheme.surface.opacity(0.4)
    }

    var borderColor: Color {
        if case .blocked = response.state { return AtlasCodePalette.alert.opacity(0.35) }
        return AtlasTheme.separator
    }

    var accessibilityText: String {
        switch response.state {
        case .mirrored: return "Espelho: tudo espelhado"
        case .pending(let commits): return "Espelho: \(commits) commits ainda só no Mac"
        case .blocked(let rules): return "Espelho bloqueado: segredo detectado, regras \(rules.joined(separator: ", "))"
        case .noMirror: return "Espelho: nenhum configurado"
        case .unknown: return "Espelho: não consegui ler o estado"
        }
    }

    func label(_ text: String, color: Color, icon: String) -> some View {
        HStack(spacing: 7) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
            Text(text)
                .font(.system(size: 12.5))
        }
        .foregroundStyle(color)
    }
}
