import SwiftUI
import AtlasCore

struct Workspace: Identifiable, Hashable {
    let id: String     // chave = nome de pasta minúsculo
    let name: String   // exibição
    let count: Int
}

// Área/modo de uma conversa. Heurística por surface + metadata (o dado de modo é
// esparso hoje; conforme o servidor popular current_mode/routing_domain, afina).
// of(_:) → AtlasArea+Of.swift
enum AtlasArea: String, CaseIterable, Identifiable {
    case tudo, operacional, autonomos, programacao
    var id: String { rawValue }
    var label: String {
        switch self {
        case .tudo: return "Tudo"
        case .operacional: return "Operacional"
        case .autonomos: return "Autônomos"
        case .programacao: return "Programação"
        }
    }
}
