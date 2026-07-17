import SwiftUI
import AtlasCore

// AtlasArea labels — peel de AtlasWorkspace.

extension AtlasArea {
    var label: String {
        switch self {
        case .tudo: return "Tudo"
        case .operacional: return "Operacional"
        case .autonomos: return "Autônomos"
        case .programacao: return "Programação"
        }
    }
}
