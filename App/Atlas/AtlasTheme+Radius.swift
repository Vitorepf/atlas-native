import Foundation

// Raio canônico — peel de AtlasTheme (padrão documentado, decisão §6).
//
// Três raios e só três: card (superfícies/cartões), control (controles,
// recibos, blocos internos), soft (chrome menor: banners, scrubber).
// Valor fora da lei é escolha deliberada e leva comentário no local
// (ex.: composer 26 = cápsula da pílula de escrita).

extension AtlasTheme {
    enum Radius {
        static let card: CGFloat = 14
        static let control: CGFloat = 12
        static let soft: CGFloat = 10
    }
}
