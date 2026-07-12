import SwiftUI

// Paleta e tokens no espírito do Cursor mobile: quase-preto com elevação sutil
// (nada de #000 chapado), monocromático, acento discreto, respiro generoso.
// SF Pro (system) — sem fonte custom nesta direção.
enum AtlasTheme {
    static let bg = Color(hex: 0x0A0A0B)          // fundo base, quase-preto vivo
    static let surface = Color(hex: 0x161618)     // botões, pílula de input
    static let surfaceHi = Color(hex: 0x202024)   // pressionado / realce
    static let separator = Color(hex: 0x1F1F22)   // divisores finos
    static let textPrimary = Color(hex: 0xF3F3F4)
    static let textSecondary = Color(hex: 0x8A8A8F)
    static let textTertiary = Color(hex: 0x5A5A60)
    static let accent = Color(hex: 0xE8B23A)      // estrela dourada do Atlas, usada com parcimônia

    enum Space {
        static let screen: CGFloat = 20           // padding horizontal da tela
        static let row: CGFloat = 16              // vertical das linhas
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}
