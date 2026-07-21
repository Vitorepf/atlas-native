import SwiftUI
import AtlasCore

// Labels dos filtros — gramática AX v4 (operador): main / fora, não trunk / desvios.

extension AtlasCodeGraphStateFilter {
    var labelHealthy: String? {
        switch self {
        case .all: return "todos"
        case .onMain: return "main"
        case .healed: return "curados"
        default: return nil
        }
    }
}
