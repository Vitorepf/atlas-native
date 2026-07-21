import AtlasCore
import SwiftUI

// Cycle 041 fuse → AtlasCodeFileRow.swift

/// Uma linha por arquivo. O VERBO é a forma do símbolo, não a cor: cor aqui
/// é reservada ao estado do commit (main/fora/curado) e mentiria se pintasse
/// tipo de mudança de vermelho dentro de um commit saudável.
struct AtlasCodeFileRow: View {
    let file: AtlasCodeFileChange
    var accessibilityIdentifier: String?

    var body: some View {
        lead
            .padding(.vertical, 9)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(AtlasCodeFileRowA11y.spokenFile(file))
            .accessibilityIdentifier(accessibilityIdentifier ?? "")
    }
}
