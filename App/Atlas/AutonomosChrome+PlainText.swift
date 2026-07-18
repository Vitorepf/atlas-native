import Foundation

// Limpeza cosmética de títulos vindos do servidor: tira ruído de máquina
// (underscores, prefixos de path relativos) sem mudar o significado.

extension AutonomosChrome {
    static func plainSlugText(_ raw: String) -> String {
        raw.replacingOccurrences(of: "../", with: "")
            .replacingOccurrences(of: "_", with: " ")
    }
}
