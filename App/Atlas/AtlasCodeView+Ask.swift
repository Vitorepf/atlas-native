import SwiftUI
import AtlasCore

// openAskFromProvenance — peel de AtlasCodeView (régua ≤100).

extension AtlasCodeView {
    func openAskFromProvenance(_ node: AtlasCodeGraphNode) {
        selectedNode = nil
        var citado = String(node.hash.prefix(10))
        var tamanho = 10
        while !citado.contains(where: \.isNumber), tamanho < node.hash.count {
            tamanho += 4
            citado = String(node.hash.prefix(tamanho))
        }
        askDraft = "o que o commit \(citado) fez, e por quê?"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) { showsAskCard = true }
    }
}
