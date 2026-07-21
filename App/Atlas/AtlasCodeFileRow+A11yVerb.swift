import AtlasCore
import Foundation
import SwiftUI

// Cycle 041 fuse → AtlasCodeFileRow+A11yVerb.swift

extension AtlasCodeFileRowA11y {
    static func verbMutate(for status: AtlasCodeFileStatus) -> String? {
        switch status {
        case .added: return "adicionado"
        case .modified: return "alterado"
        case .deleted: return "removido"
        default: return nil
        }
    }
}

extension AtlasCodeFileRowA11y {
    static func verbRenameCopy(for status: AtlasCodeFileStatus) -> String? {
        switch status {
        case .renamed: return "renomeado"
        case .copied: return "copiado"
        default: return nil
        }
    }
}

extension AtlasCodeFileRowA11y {
    static func verbTransform(for status: AtlasCodeFileStatus) -> String {
        if let rename = verbRenameCopy(for: status) { return rename }
        switch status {
        case .typeChanged: return "tipo alterado"
        case .unknown: return "mudança desconhecida"
        default: return verbMutate(for: status) ?? "mudança desconhecida"
        }
    }
}

extension AtlasCodeFileRowA11y {
    static func verb(for status: AtlasCodeFileStatus) -> String {
        verbMutate(for: status) ?? verbTransform(for: status)
    }
}

extension AtlasCodeFileRow {
    var subtitle: String? {
        if let from = file.renamedFrom { return "de \(from)" }
        return file.directory
    }
}

extension AtlasCodeFileRow {
    var symbolMutate: String? {
        switch file.status {
        case .added: return "plus"
        case .modified: return "pencil"
        case .deleted: return "minus"
        default: return nil
        }
    }
}

extension AtlasCodeFileRow {
    var symbolTransform: String? {
        switch file.status {
        case .renamed: return "arrow.right"
        case .copied: return "doc.on.doc"
        case .typeChanged: return "arrow.triangle.2.circlepath"
        default: return nil
        }
    }
}

extension AtlasCodeFileRow {
    var symbol: String {
        symbolMutate ?? symbolTransform ?? "questionmark"
    }
}
