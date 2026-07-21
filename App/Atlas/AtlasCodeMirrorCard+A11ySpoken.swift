import AtlasCore
import SwiftUI

/// Spoken mirror label — peel de AtlasCodeMirrorCard+A11y.
/// Só fala host e contagens reais do payload; ausência nunca vira zero fabricado.
/// State → AtlasCodeMirrorCard+A11ySpokenState.swift

extension AtlasCodeMirrorCard {
    func spokenMirrorLabel() -> String {
        var parts: [String] = ["Espelho"]
        parts.append(contentsOf: spokenMirrorStateParts())
        if let host = response.mirror?.host, !host.isEmpty {
            parts.append("host \(host)")
        }
        return parts.joined(separator: ", ")
    }

    static let mirrorHint = "cópia remota do repositório e varredura de segredos no Mac"
}
