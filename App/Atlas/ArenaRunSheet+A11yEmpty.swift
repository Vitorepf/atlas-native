import Foundation
import AtlasCore

// Empty engines/suites spoken — peel de ArenaRunSheet+A11y.

extension ArenaRunSheet {
    func spokenEmptyEngines() -> String {
        "nenhum motor publicado pelo servidor, rodar medição indisponível"
    }

    func spokenEmptySuites() -> String {
        "nenhuma suite com adapter instalado, rodar medição indisponível"
    }
}
