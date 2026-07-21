import AtlasCore
import SwiftUI

// IDLE-COMPRESS fused

// --- AtlasWorkspace.swift ---
struct Workspace: Identifiable, Hashable {
    let id: String     // chave = nome de pasta minúsculo
    let name: String   // exibição
    let count: Int
}

enum AtlasArea: String, CaseIterable, Identifiable {
    case tudo, operacional, autonomos, programacao
    var id: String { rawValue }
}

// --- AtlasWorkspace+AreaLabel.swift ---
extension AtlasArea {
    var label: String {
        labelDomain ?? "Tudo"
    }
}

// --- AtlasWorkspace+AreaLabel+Domain.swift ---
extension AtlasArea {
    var labelDomain: String? {
        switch self {
        case .operacional: return "Operacional"
        case .autonomos: return "Autônomos"
        case .programacao: return "Programação"
        default: return nil
        }
    }
}
