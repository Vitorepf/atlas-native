import SwiftUI

// Domain + space tokens — peel de AtlasTheme.

extension AtlasTheme {
    // Cores de domínio com uso real na casca
    static let domOperacional = Color(hex: 0x9B7A3F) // bronze
    static let domAutonomos = Color(hex: 0x6FA06A)   // verde (moss clareado p/ dark)

    enum Space {
        static let screen: CGFloat = 20
        /// Ritmo vertical das rows da home — um pouco mais compacto que o body
        /// padrão, sem apertar o alvo de toque.
        static let row: CGFloat = 13
    }
}
