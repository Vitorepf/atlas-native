import Foundation
import AtlasCore

// Preferências de APRESENTAÇÃO do composer — fora de View por constituição
// (o boundary check "Views não fazem rede, JSON ou storage" é mecânico).
// Presentation-only: nada aqui toca rede ou lógica de envio.
@MainActor
enum ComposerPrefs {
    private static let effortKey = "atlas.composer.effort"

    static var effort: AtlasComputeEffort {
        get { AtlasComputeEffort(rawValue: UserDefaults.standard.string(forKey: effortKey) ?? "") ?? .auto }
        set { UserDefaults.standard.set(newValue.rawValue, forKey: effortKey) }
    }
}
